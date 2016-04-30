//
//  Action.swift
//  Editor4
//
//  Created by Hoon H. on 2016/04/30.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation.NSURL

/// Action definitions can be nested to provide:
/// - Semantic locality
/// - Common contextual parameter
/// .

enum Action {
    /// The first action to activate driver.
    case Reset
    case Menu(MainMenuAction)
    case Shell(ShellAction)
    case Workspace(id: WorkspaceID, command: WorkspaceAction)
}
enum MenuAction {
    case RunMainMenuItem(MainMenuAction)
}
enum ShellAction {
    case Quit
    case RunCreatingWorkspaceDialogue
    case RunOpeningWorkspaceDialogue
    case NewWorkspace(NSURL)
    case OpenWorkspace(NSURL)
}
enum WorkspaceAction {
    case Close(WorkspaceID)
    case MakeKey(WorkspaceID)
    case File(FileAction)
    case Editor(EditorAction)
    //        case FileNode(path: WorkspaceItemPath, FileNodeAction)
    //        case FileNodeList(paths: [WorkspaceItemPath], FileNodeAction)
    case Build(BuildAction)
    case Debug(DebugAction)
}
enum FileAction {
    case NewFolder
    case NewFile
    case SelectAll
    case DeselectAll
    case Delete
    case Drop(from: [NSURL], onto: WorkspaceItemPath)
    case Move(from: [WorkspaceItemPath], onto: WorkspaceItemPath)
}
//enum FileNodeAction {
//        case Select
//        case Deselect
//        case Delete
//}
enum EditorAction {
    case Open(NSURL)
    case Save
    case Close
    case TextEditor(TextEditorAction)
}
enum TextEditorAction {
}
enum AutocompletionAction {
    case ShowCandidates
    case HideCandidates
    case ReconfigureCandidates(expression: String)
}
enum BuildAction {
    case Clean
    case Build
}
enum DebugAction {
    case Launch
    case Halt
    case Pause
    case Resume
    case StepInto
    case StepOver
    case StepOut
    case SelectStackFrame(index: Int)
    case DeselectStackFrame
//        case SelectSlotVariable(index: Int)
//        case DeselectSlotVariable
    case PrintSlotVariable(index: Int)
}







