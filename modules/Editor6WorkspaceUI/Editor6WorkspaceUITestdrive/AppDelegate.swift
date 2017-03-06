//
//  AppDelegate.swift
//  Editor6WorkspaceUITestdrive
//
//  Created by Hoon H. on 2016/10/15.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Cocoa
import AppKit
import Editor6Common
import Editor6WorkspaceUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var s = WorkspaceUIState()
    private let wc = WorkspaceUIWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        wc.delegate = { (action: WorkspaceUIAction) in
            Swift.print(action)
        }

        s.navigator.files.tree[s.navigator.files.tree.root.id].name = "hihi!"
        let newFileID = s.navigator.files.tree.insert(at: 0, in: s.navigator.files.tree.root.id)
        s.navigator.files.tree[newFileID].name = "(file 1)"

        do {
            var n = WorkspaceUIBasicOutlineNodeState()
            n.label = "AAAAA"
            var t = WorkspaceUIBasicOutlineState.Tree(state: n)
            n.label = "BBBB"
            t.insert(n, at: 0, in: t.root.id)
            n.label = "cccc"
            t.insert(n, at: 1, in: t.root.id)
            s.navigator.issues.tree = t
        }
        wc.reload(s)
        wc.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}


//@NSApplicationMain
//class AppDelegate: NSObject, NSApplicationDelegate {
//    var s = WorkspaceUIState()
//
//    @IBOutlet weak var window: NSWindow!
//    private let vc = WorkspaceUIViewController()
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        window.contentViewController = vc
//        s.navigator.files.tree[s.navigator.files.tree.root.id].name = "hihi!"
//        let newFileID = s.navigator.files.tree.insert(at: 0, in: s.navigator.files.tree.root.id)
//        s.navigator.files.tree[newFileID].name = "(file 1)"
//
//        do {
//            var n = WorkspaceUIBasicOutlineNodeState()
//            n.label = "AAAAA"
//            var t = WorkspaceUIBasicOutlineState.Tree(state: n)
//            t.insert(n, at: 0, in: t.root.id)
////            let id1 = t.insert(n, at: 1, in: t.root.id)
//            t.insert(n, at: 1, in: t.root.id)
////            t.insert(n, at: 0, in: id1)
//            s.navigator.issues.tree = t
//        }
//
//        vc.reload(s)
//    }
//
//    func applicationWillTerminate(_ aNotification: Notification) {
//        // Insert code here to tear down your application
//    }
//
//
//}

