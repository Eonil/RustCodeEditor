//
//  CargoProcess2.swift
//  Editor
//
//  Created by Hoon H. on 2017/06/25.
//  Copyright © 2017 Eonil. All rights reserved.
//

import Foundation

final class CargoProcess2 {
    let parameters: Parameters
    let signal = Relay<()>()
    /// Provides detailed information of what's been changed.
    let transaction = Relay<Transaction>()
    private let loop = ReactiveLoop()
    private let bash = BashProcess2(login: true)
    private(set) var state = State.running
    private(set) var props = Props()
    private var outlb = LineBuilder()
    private var errlb = LineBuilder()

    init(_ ps: Parameters) {
        precondition(ps.location.isFileURL)
        precondition(FileManager.default.fileExists(atPath: ps.location.path))
        parameters = ps
        loop.step = { [weak self] in self?.step() }
        bash.signal += loop
        let args = ps.command.makeCommandLineArguments()
        let script = [
            "cd \(parameters.location.path)",
            (["cargo"] + args).joined(separator: " "),
            "exit $?",
            ].map({  $0 + "\n" }).joined()
        let scriptd = AUDIT_unwrap(script.data(using: .utf8), [
            "Fail to encode script using UTF-8...",
            "",
            script,
            ].joined(separator: "\n"))
        bash.queue(.stdin(scriptd))
    }
    deinit {
    }
    private func step() {
        switch state {
        case .running:
            for d in bash.takeOutStandardOutput() {
                switch outlb.process(d) {
                case .failure(let issue):
                    let c = props.issues.count
                    props.issues.append(.cannotDecodeStandardOutput(issue))
                    signal.cast()
                    transaction.cast(.issues(.insert(c..<c+1)))
                case .success(let lines):
                    DEBUG_log("Bash STDOUT:\n\(lines)")
                    let c = props.issues.count
                    props.issues.append(.unexpectedStandardOutput(lines.joined()))
                    signal.cast()
                    transaction.cast(.issues(.insert(c..<c+1)))
                }
            }
            for d in bash.takeOutStandardError() {
                switch errlb.process(d) {
                case .failure(let issue):
                    let c = props.issues.count
                    props.issues.append(.cannotDecodeStandardError(issue))
                    signal.cast()
                    transaction.cast(.issues(.insert(c..<c+1)))
                case .success(let lines):
                    DEBUG_log("Bash STDERR:\n\(lines)")
                    switch parameters.command {
                    case .initialize:
                        // For any output, it's an error.
                        let msg = lines.joined(separator: "\n")
                        let c = props.reports.count
                        props.reports.append(.cargoErr(msg))
                        signal.cast()
                        transaction.cast(.reports(.insert(c..<c+1)))

                    case .clean:
                        DEBUG_log("Receive STDERR: \(lines)")
                        MARK_unimplementedButSkipForNow()
                        
                    case .build:
                        DEBUG_log("Receive STDERR: \(lines)")
                        MARK_unimplementedButSkipForNow()

                    case .run:
                        MARK_unimplemented()
                    }
                }
            }
            bash.clearStandardError()
            switch bash.state {
            case .running: break
            case .complete(let exitCode):
                state = .complete
                signal.cast()
                transaction.cast(.state)
                guard exitCode == 0 else { return props.issues.append(.bsahSubprocessExitWithNonZeroCode(exitCode)) }
            }

        case .complete:
            break
        }
    }
    func setPriority(_ newPriority: Priority) {
        props.priority = newPriority
        switch props.priority {
        case .primary:
            bash.queue(.setPrimary)
        case .secondary:
            bash.queue(.setSecondary)
        }
        signal.cast()
        transaction.cast(.priority)
    }
}
extension CargoProcess2 {
    struct Parameters {
        var location: URL
        var command: Command
    }
    enum Command {
        case initialize(InitParams)
        case clean
        case build
        case run
    }
    struct InitParams {
        var name = ""
        var type = ProjectType.lib
    }
    enum ProjectType {
        case lib
        case bin
    }
    enum State {
        case running
        case complete
    }
    struct Props {
        var priority = Priority.secondary
        var reports = [Report]()
        var issues = [Issue]()
    }
    enum Priority {
        case primary
        case secondary
    }
    ///
    /// Output emission from Cargo operation.
    /// This is problems of input files for Cargo operation.
    /// Cargo execution itself is OK.
    ///
    enum Report {
        case info(String)
        case cargoErr(String)
        case rustCompWarn
        case rustCompErr
    }
    enum Transaction {
        case state
        case priority
        case reports(ArrayMutation<Report>)
        case issues(ArrayMutation<Issue>)
    }
    ///
    /// Cargo execution failure reason.
    /// Don't be confused. This means an error in Cargo execution.
    ///
    enum Issue {
        case cannotDecodeStandardOutput(LineBuilder.Issue)
        case cannotDecodeStandardError(LineBuilder.Issue)
        case unexpectedStandardOutput(String)
        case bsahSubprocessExitWithNonZeroCode(Int32)
    }
}

private extension CargoProcess2.Command {
    func makeCommandLineArguments() -> [String] {
        switch self {
        case .initialize(let ps):   return ["init"] + ps.makeSubarguments()
        case .clean:                return ["clean", "--message-format=json"]
        case .build:                return ["build", "--message-format=json"]
        case .run:                  return ["run", "--message-format=json"]
        }
    }
}
private extension CargoProcess2.InitParams {
    func makeSubarguments() -> [String] {
        var a = [String]()
        if name != "" {
            a += ["--name", name]
        }
        switch type {
        case .lib:
            a += ["--lib"]
        case .bin:
            a += ["--bin"]
        }
        return a
    }
}

private extension BashProcess2 {
    /// Copy, erase, and return STDOUT.
    func takeOutStandardOutput() -> [Data] {
        let copy = props.stdout
        clearStandardOutput()
        return copy
    }
    /// Copy, erase, and return STDERR.
    func takeOutStandardError() -> [Data] {
        let copy = props.stderr
        clearStandardError()
        return copy
    }
}
