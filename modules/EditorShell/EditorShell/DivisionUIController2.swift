//
//  DivisionUIController2.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/11/12.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import EditorCommon
import EditorModel
import EditorUICommon

class DivisionUIController2: CommonViewController {









	


	///

	weak var model: WorkspaceModel? {
		didSet {
			_navigationVC.model	=	model
			_consoleVC.model	=	model
//			_inspectionVC.model	=	model
			_editingVC.model	=	model
		}
	}














	///

	override func installSubcomponents() {
		super.installSubcomponents()
		_install()
	}
	override func deinstallSubcomponents() {
		_deinstall()
		super.deinstallSubcomponents()
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		_layout()
	}

















	



	///

	private let _outerSplitVC		=	_instantiateOuterSplitViewController()
	private let _innerSplitVC		=	_instantiateInnerSplitViewController()

	private let _outerLeftSplitItem		=	NSSplitViewItem()
	private let _outerRightSplitItem	=	NSSplitViewItem()
	private let _innerTopSplitItem		=	NSSplitViewItem()
	private let _innerBottomSplitItem	=	NSSplitViewItem()

	private let _navigationVC		=	NavigationUIController()
	private let _consoleVC			=	ConsoleUIController()
	private let _inspectionVC		=	DummyViewController()
	private let _editingVC			=	EditUIController()

	private var _splitItems			:	(outer: (left: NSSplitViewItem, right: NSSplitViewItem), inner: (top: NSSplitViewItem, bottom: NSSplitViewItem))?
	private var _collapsingState		:	(outer: (left: Bool, right: Bool), inner: (top: Bool, bottom: Bool))?

//	private var _splitItemMapping		=	Dictionary<ReferentialIdentity<NSViewController>, NSSplitView>()

	private func _install() {
		assert(view.window!.appearance != nil)
		assert(view.window!.appearance!.name == NSAppearanceNameVibrantDark)
		
		view.wantsLayer					=	true
		view.layer!.backgroundColor			=	WindowBackgroundFillColor.CGColor
		_outerSplitVC.view.wantsLayer			=	true
		_outerSplitVC.view.layer!.backgroundColor	=	WindowBackgroundFillColor.CGColor
		_outerSplitVC.splitView.wantsLayer		=	true
		_outerSplitVC.splitView.layer!.backgroundColor	=	WindowBackgroundFillColor.CGColor
		_innerSplitVC.view.wantsLayer			=	true
		_innerSplitVC.view.layer!.backgroundColor	=	WindowBackgroundFillColor.CGColor

		// Initial metrics defines initial layout. We need these.
		_navigationVC.view.frame.size.width	=	200
		_inspectionVC.view.frame.size.width	=	200
		_consoleVC.view.frame.size.height	=	100

		func navItem() -> NSSplitViewItem {
			let	m	=	NSSplitViewItem(sidebarWithViewController: _navigationVC)
			m.minimumThickness		=	100
			m.preferredThicknessFraction	=	0.1
			m.automaticMaximumThickness	=	100
			m.canCollapse			=	true
			return	m
		}
		func inspItem() -> NSSplitViewItem {
			let	m	=	NSSplitViewItem(contentListWithViewController: _inspectionVC)
			m.minimumThickness		=	100
			m.preferredThicknessFraction	=	0.1
			m.automaticMaximumThickness	=	100
			m.canCollapse			=	true
			return	m
		}
		func centerItem() -> NSSplitViewItem {
			let	m	=	NSSplitViewItem(viewController: _innerSplitVC)
			m.minimumThickness		=	100
			m.preferredThicknessFraction	=	0.8
			m.automaticMaximumThickness	=	NSSplitViewItemUnspecifiedDimension
			return	m
		}
		func consoleItem() -> NSSplitViewItem {
			let	m	=	NSSplitViewItem(viewController: _consoleVC)
			m.minimumThickness		=	100
			m.preferredThicknessFraction	=	0.1
			m.automaticMaximumThickness	=	100
			m.canCollapse			=	true
			return	m
		}
		func editItem() -> NSSplitViewItem {
			let	m	=	NSSplitViewItem(viewController: _editingVC)
			m.minimumThickness		=	100
			m.preferredThicknessFraction	=	0.9
			m.automaticMaximumThickness	=	NSSplitViewItemUnspecifiedDimension
			return	m
		}


		_splitItems	=	(
			outer:
				(left:	navItem(),
				right:	inspItem()),
			inner:
				(top:	editItem(),
				bottom:	consoleItem()))

		_innerSplitVC.splitView.vertical	=	false
		_innerSplitVC.splitViewItems		=	[
			_splitItems!.inner.top,
			_splitItems!.inner.bottom,
		]
		_outerSplitVC.splitViewItems		=	[
			_splitItems!.outer.left,
			centerItem(),
			_splitItems!.outer.right,
		]
		addChildViewController(_outerSplitVC)
		view.addSubview(_outerSplitVC.view)

		NSNotificationCenter.defaultCenter().addUIObserver	(self, DivisionUIController2._process, NSSplitViewDidResizeSubviewsNotification)
		UIState.ForWorkspaceModel.Notification.register		(self, DivisionUIController2._process)
	}
	private func _deinstall() {
		UIState.ForWorkspaceModel.Notification.deregister	(self)
		NSNotificationCenter.defaultCenter().removeUIObserver	(self, NSSplitViewDidResizeSubviewsNotification)

		_outerSplitVC.view.removeFromSuperview()
		_outerSplitVC.removeFromParentViewController()
		_outerSplitVC.splitViewItems		=	[]
		_innerSplitVC.splitViewItems		=	[]
		_splitItems				=	nil
	}
	private func _layout() {
		_outerSplitVC.view.frame		=	view.bounds
	}
















	/// 

	private func _getCollapsingState() -> (outer: (left: Bool, right: Bool), inner: (top: Bool, bottom: Bool)) {
		return	(
			(_splitItems!.outer.left.collapsed, _splitItems!.outer.right.collapsed),
			(_splitItems!.inner.top.collapsed, _splitItems!.inner.bottom.collapsed))
	}
	private func _process(n: NSNotification) {
		guard n.object === _outerSplitVC.splitView || n.object === _innerSplitVC.splitView else {
			return
		}

		switch n.name {
		case NSSplitViewDidResizeSubviewsNotification:
			let	oldState	=	_collapsingState ?? _getCollapsingState()
			let	newState	=	_getCollapsingState()
			let	noChange	=	newState.outer.left == oldState.outer.left
						&&	newState.outer.right == oldState.outer.right
						&&	newState.inner.top == oldState.inner.top
						&&	newState.inner.bottom == oldState.inner.bottom

			if noChange == false {
				_applyInputToState()
			}

			_collapsingState	=	newState

		default:
			fatalError()
		}
	}













	///

	private func _applyInputToState() {
		model!.overallUIState.mutate {
			$0.navigationPaneVisibility		=	_splitItems!.outer.left.collapsed == false
			$0.inspectionPaneVisibility		=	_splitItems!.outer.right.collapsed == false
			$0.consolePaneVisibility		=	_splitItems!.inner.bottom.collapsed == false
		}
	}










	///

	private func _process(n: UIState.ForWorkspaceModel.Notification) {
		guard model === n.sender else {
			return
		}
		_applyStateChanges()
	}
	private func _applyStateChanges() {
		model!.overallUIState.with {
			_splitItems!.outer.left.collapsed	=	$0.navigationPaneVisibility == false
			_splitItems!.outer.right.collapsed	=	$0.inspectionPaneVisibility == false
			_splitItems!.inner.bottom.collapsed	=	$0.consolePaneVisibility == false
		}
	}


}



































private func _instantiateOuterSplitViewController() -> PaneSplitViewController {
	let	vc				=	PaneSplitViewController()
	vc.paneSplitView.dividerThickness	=	0
	vc.paneSplitView.dividerColor		=	NSColor.clearColor()
	return	vc
}
private func _instantiateInnerSplitViewController() -> PaneSplitViewController {
	let	vc				=	PaneSplitViewController()
	vc.paneSplitView.dividerThickness	=	1
	vc.paneSplitView.dividerColor		=	WindowDivisionSplitDividerColor
	return	vc
}





//private class _OuterSplitView: NSSplitView {
//	override var dividerColor: NSColor {
//		get {
//			return	NSColor.clearColor()
//		}
//	}
//	override var dividerThickness: CGFloat {
//		get {
//			return	0
//		}
//	}
////	private override func drawDividerInRect(rect: NSRect) {
////		// Do nothing.
////		return
////	}
//}
//private class _OuterSplitViewController: NSSplitViewController {
//	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//		let	v					=	_OuterSplitView()
//		v.translatesAutoresizingMaskIntoConstraints	=	false
//		v.vertical					=	true
//		v.dividerStyle					=	.Thin
//		splitView					=	v
//	}
//	required init?(coder: NSCoder) {
//		fatalError()
//	}
//	private override func viewDidLoad() {
//		super.viewDidLoad()
//	}
//}
//
//
//private class _InnerSplitView: NSSplitView {
//	override var dividerColor: NSColor {
//		get {
//			return	WindowDivisionSplitDividerColor
//		}
//	}
//}
//private class _InnerSplitViewController: NSSplitViewController {
//	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//		let	v					=	_InnerSplitView()
//		v.translatesAutoresizingMaskIntoConstraints	=	false
//		v.vertical					=	true
//		v.dividerStyle					=	.Thin
//		splitView					=	v
//	}
//	required init?(coder: NSCoder) {
//		fatalError()
//	}
//	private override func viewDidLoad() {
//		super.viewDidLoad()
//	}
//}
//








