//
//  AppKitExtensions.swift
//  RustCodeEditor
//
//  Created by Hoon H. on 11/11/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit

extension NSViewController {
//	var childViewControllers:[NSViewController] {
//		get {
//			
//		}
//	}
	func indexOfChildViewController(vc:NSViewController) -> Int? {
		for i in 0..<self.childViewControllers.count {
			let	vc1	=	self.childViewControllers[i] as NSViewController
			if vc1 === vc {
				return	i
			}
		}
		return	nil
	}
	func removeChildViewController<T:NSViewController>(vc:T) {
		if let idx1 = self.indexOfChildViewController(vc) {
			self.removeChildViewControllerAtIndex(idx1)
		} else {
			fatalError("The view-controller is not a child of this view-controller.")
		}
	}
}


extension NSView {
	var layoutConstraints:[NSLayoutConstraint] {
		get {
			return	self.constraints as [NSLayoutConstraint]
		}
		set(v) {
			self.removeConstraints(self.constraints)
			self.addConstraints(v as [AnyObject])
		}
	}
}

extension NSTextView {
//	var selectedRanges:[NSRange] {
//		get {
//			return	self.selectedRanges.map({$0.rangeValue})
//		}
//		set(v) {
//			self.selectedRanges	=	v.map({NSValue(range: $0)})
//		}
//	}
}

extension NSTableColumn {
	convenience init(identifier:String, title:String) {
		self.init(identifier: identifier)
		self.title		=	title
	}
	convenience init(identifier:String, title:String, width:CGFloat) {
		self.init(identifier: identifier)
		self.title		=	title
		self.width		=	width
	}
}




extension NSLayoutManager {
	
}




