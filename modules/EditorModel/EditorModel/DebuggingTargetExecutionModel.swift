//
//  DebuggingTargetExecutionModel.swift
//  EditorModel
//
//  Created by Hoon H. on 2015/08/21.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import MulticastingStorage
import LLDBWrapper
import EditorCommon

public class DebuggingTargetExecutionModel: ModelSubnode<DebuggingTargetModel>, BroadcastingModelType {

	public typealias	State	=	LLDBStateType







	
	///

	internal init(LLDBProcess lldbProcess: LLDBProcess) {
		_lldbProcess	=	lldbProcess
	}










	///

	public let event	=	EventMulticast<Event>()

	public var target: DebuggingTargetModel {
		get {
			assert(owner != nil)
			return	owner!
		}
	}

	public override func didJoinModelRoot() {
		super.didJoinModelRoot()
		_install()
	}
	public override func willLeaveModelRoot() {
		_deinstall()
		super.willLeaveModelRoot()
	}

	///

	public var LLDBObject: LLDBProcess {
		get {
			return	_lldbProcess
		}
	}

	public private(set) var runnableCommands: Set<DebuggingCommand> = [] {
		willSet {
			Event.WillMutate.dualcastAsNotificationWithSender(self)
		}
		didSet {
			Event.DidMutate.dualcastAsNotificationWithSender(self)
		}
	}
	public private(set) var state: LLDBStateType = .Invalid {
		willSet {
			Event.WillMutate.dualcastAsNotificationWithSender(self)
		}
		didSet {
			Event.DidMutate.dualcastAsNotificationWithSender(self)
		}
	}

	public func runCommand(command: DebuggingCommand) {
		switch command {
		case .Halt:
			halt()
		case .Pause:
			pause()
		case .Resume:
			resume()
		case .StepInto:
			stepInto()
		case .StepOut:
			stepOut()
		case .StepOver:
			stepOver()
		}
	}

	public func pause() {
		_lldbProcess.stop()
	}
	public func resume() {
		_lldbProcess.`continue`()
	}
	public func halt() {
		_lldbProcess.kill()
		_reapplyRunnableCommandState()
	}

	public func stepInto() {
		if let th = _findFirstSuspendedThread() {
			th.stepInto()
		}
		else {
			assert(false)
		}
	}
	public func stepOut() {
		if let th = _findFirstSuspendedThread() {
			th.stepOut()
		}
		else {
			assert(false)
		}
	}
	public func stepOver() {
		if let th = _findFirstSuspendedThread() {
			th.stepOver()
		}
		else {
			assert(false)
		}
	}

















	///

	private let	_lldbProcess		:	LLDBProcess
//	private let	_eventWaiter		=	DebuggingEventWaiter()
	private let	_eventWaiter		=	DebuggingListener()

	///

	private func _install() {
		_reapplyRunnableCommandState()

		_eventWaiter.onEvent	=	{ [weak self] in self?._handleLLDBEvent($0) }
		_lldbProcess.addListener(_eventWaiter.listener, eventMask: LLDBProcess.BroadcastBit.StateChanged)
		_eventWaiter.run()
	}
	private func _deinstall() {
		_eventWaiter.halt()
		_lldbProcess.removeListener(_eventWaiter.listener, eventMask: LLDBProcess.BroadcastBit.StateChanged)
		_eventWaiter.onEvent	=	nil
//		target.debugging.event.deregister(ObjectIdentifier(self))

		_reapplyRunnableCommandState()
	}

	private func _reapplyRunnableCommandState() {
		Debug.log(_lldbProcess.state)
		runnableCommands	=	_runnableCommandsForProcess(_lldbProcess)
	}


	private func _handleLLDBEvent(e: LLDBEvent) {
		Debug.assertMainThread()
		state	=	_lldbProcess.state
		_reapplyRunnableCommandState()
	}

	///

	private func _findFirstSuspendedThread() -> LLDBThread? {
		for th in _lldbProcess.allThreads {
			switch th.stopReason {
			case .Breakpoint:
				fallthrough
			case .Exception:
				fallthrough
			case .Exec:
				fallthrough
			case .PlanComplete:
				fallthrough
			case .Signal:
				fallthrough
			case .ThreadExiting:
				fallthrough
			case .Trace:
				fallthrough
			case .Watchpoint:
				return	th

				// Ignore.
			case .Instrumentation:
				break

			case .Invalid:
				fallthrough
			case .None:
				fatalError("I don't know why these happen.")
			}
		}
		return	nil
	}
}






























private func _runnableCommandsForProcess(process: LLDBProcess) -> Set<DebuggingCommand> {
	switch process.state {
	case .Stopped:
		fallthrough
	case .Suspended:
		return	[.Resume, .StepOver, .StepInto, .StepOut]

	case .Running:
		fallthrough
	case .Stepping:
		return	[.Halt, .Pause]

	case .Attaching:
		fallthrough
	case .Connected:
		fallthrough
	case .Crashed:
		fallthrough
	case .Detached:
		fallthrough
	case .Exited:
		fallthrough
	case .Invalid:
		fallthrough
	case .Launching:
		fallthrough

	case .Unloaded:
		return	[]
	}
}
private func _runnableCommandsForThread(thread: LLDBThread) -> Set<DebuggingCommand> {
	if thread.stopped {
		return	[
			DebuggingCommand.Halt,
			DebuggingCommand.Resume,
			DebuggingCommand.StepInto,
			DebuggingCommand.StepOut,
			DebuggingCommand.StepOver,
		]
	}
	else {
		return	[
			DebuggingCommand.Halt,
			DebuggingCommand.Pause,
		]
	}
}










