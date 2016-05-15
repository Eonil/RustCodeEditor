//
//  Driver.swift
//  Editor4
//
//  Created by Hoon H. on 2016/04/20.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import BoltsSwift
import EonilToolbox

protocol Dispatchable {
}
extension Dispatchable {
    /// Returns a task which completes *eventually*
    /// after the action has been processed completely.
    /// - State is fully updated
    /// - Rendering is done.
    /// Calling of the completion is done in main thread,
    /// and will be guarantted to happend in order as it
    /// passed-in.
    func dispatch(action: Action) -> Task<()> {
        return Driver.theDriver.dispatch(action)
    }
}
protocol DriverAccessible: Dispatchable {
}
extension DriverAccessible {
    /// Currently processing action.
    /// Can be `nil` if you access this property out of
    /// action processing.
    var action: Action? {
        get { return Driver.theDriver.context }
    }
    /// Current app state.
    /// Driver guarantees no change in state while 
    /// processing an action.
    var state: State {
        get { return Driver.theDriver.state }
    }

}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct Schedule {
    var action: Action
    var completion: TaskCompletionSource<()>
}
private final class Driver {

    private static let theDriver = Driver()

    private let services = Services()
    private var schedules = [Schedule]()
    private var context: Action?
    private var state = State()
    private let shell = Shell()

    init() {
        do {
            try DisplayLinkUtility.installMainScreenHandler(ObjectIdentifier(self)) { [weak self] in
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    self?.run()
                }
            }
        }
        catch let error {
            fatalError("\(error)") // No way to recover in this case...
        }
    }
    deinit {
        DisplayLinkUtility.deinstallMainScreenHandler(ObjectIdentifier(self))
    }

    func dispatch(action: Action) -> Task<()> {
        assertMainThread()
        let schedule = Schedule(action: action, completion: TaskCompletionSource())
        schedules.append(schedule)
        return schedule.completion.task
    }
    func run() {
        assertMainThread()
        while let s = schedules.tryRemoveFirst() {
            step(s)
        }
    }
    func step(schedule: Schedule) {
        assertMainThread()
        context = schedule.action
        do {
            try state.apply(schedule.action)
            shell.render()
            schedule.completion.trySetResult(())
        }
        catch let error {
            shell.alert(error)
            schedule.completion.trySetError(error)
//            assert(false, "Error in stepping: \(error). This is only for information purpose, and you can safely ignore this assertion.")
//            fatalError("\(error)") // No way to recover in this case...
        }
        context = nil
        debugPrint("Applied action: \(schedule.action)")
    }
}

























