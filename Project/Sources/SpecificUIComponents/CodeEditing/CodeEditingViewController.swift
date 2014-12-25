//
//  CodeEditingViewController.swift
//  RustCodeEditor
//
//  Created by Hoon H. on 11/11/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit

class CodeEditingViewController : TextScrollViewController {
	
	
	var	URLRepresentation:NSURL? {
		get {
			return	self.representedObject as NSURL?
		}
		set(v) {
			self.representedObject	=	v
		}
	}
	override var representedObject:AnyObject? {
		get {
			return	super.representedObject
		}
		set(v) {
			precondition(v == nil || v! is NSURL)
			
			//	Skip duplicated assignment.
			if v as NSURL? == super.representedObject as NSURL? {
				return
			}
			
			if let u1 = URLRepresentation {
				if _trySavingContentInPlace() {
				}
				_clearContent()
			}
			
			if let u1 = v as NSURL? {
				super.representedObject	=	v
				if _tryLoadingContentOfFileAtURL(u1) {
				} else {
					super.representedObject	=	nil
					return	//	Clear errorneous value.
				}
			}
		}
//		willSet(v) {
//			precondition(v == nil || v! is NSURL)
//			if let u1 = URLRepresentation {
//				precondition(u1.existingAsDataFile)	//	Do not set non-data-file to this editor.
//				_saveContentInPlace()
//				_clearContent()
//			}
//		}
//		didSet {
//			if let u1 = URLRepresentation {
//				_loadContentOfFileAtURL(u1)
//			}
//		}
	}
	
	
	
	
	
	func trySavingInPlace() -> Bool {
		return	_trySavingContentInPlace()
	}
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.codeTextViewController.codeTextView.font								=	Palette.current.codeFont
		self.codeTextViewController.codeTextView.continuousSpellCheckingEnabled		=	false
		self.codeTextViewController.codeTextView.automaticTextReplacementEnabled	=	false
		self.codeTextViewController.codeTextView.automaticQuoteSubstitutionEnabled	=	false
		self.codeTextViewController.codeTextView.allowsUndo							=	true
		self.codeTextViewController.codeTextView.delegate							=	self
		
		assert(self.codeTextViewController.codeTextView.textStorage!.delegate === nil)
		self.codeTextViewController.codeTextView.textStorage!.delegate	=	self
	}
	
	func highlightRangesOfIssues(ss:[Issue]) {
		var	rs1	=	[] as [NSRange]
		for s in ss {
			for i in s.range.start.line...s.range.end.line {
				let	r1	=	(codeTextViewController.codeTextView.string! as NSString).findNSRangeOfLineContentAtIndex(i)
				rs1.append(r1!)
			}
		}
		codeTextViewController.codeTextView.selectedRanges	=	rs1
		codeTextViewController.codeTextView.scrollRangeToVisible(rs1[0])
	}
	func navigateRangeOfIssue(s:Issue) {
		let	r1	=	codeTextViewController.codeTextView.string!.findNSRangeOfLineContentAtIndex(s.range.start.line)
		if let r2 = r1 {
			codeTextViewController.codeTextView.window!.makeFirstResponder(codeTextViewController.codeTextView)
			codeTextViewController.codeTextView.selectedRanges	=	[r1!]
			codeTextViewController.codeTextView.scrollRangeToVisible(r1!)
		} else {
		}
	}
	
	
	override func instantiateDocumentViewController() -> NSViewController {
		return	CodeTextViewController()
	}
}
extension CodeEditingViewController {
	var codeTextViewController:CodeTextViewController {
		get {
			return	super.textViewController as CodeTextViewController
		}
	}
	@availability(*,unavailable)
	override var textViewController:TextViewController {
		get {
			return	super.textViewController
		}
	}
}
extension CodeEditingViewController: NSTextStorageDelegate {
	func textStorageWillProcessEditing(notification: NSNotification) {
		assert(notification.name == NSTextStorageWillProcessEditingNotification)
		applySyntaxHighlight(self.codeTextViewController.codeTextView)
	}
	func textStorageDidProcessEditing(notification: NSNotification) {
	}
}

private func applySyntaxHighlight(textView:NSTextView) {
	let	s	=	textView.textStorage!
	let	x	=	SyntaxHighlighting(targetTextView: textView)
	x.applyAll()
}
















class CodeTextViewController: TextViewController {
}
extension CodeTextViewController {
	var codeTextView:CodeTextView {
		get {
			return	super.textView as CodeTextView
		}
	}
	@availability(*,unavailable)
	override var textView:NSTextView {
		get {
			return	super.textView
		}
	}
	
	override func instantiateTextView() -> NSTextView {
		return	CodeTextView()
	}
}
class CodeTextView: NSTextView {
	private var	autocompletionC: CodeTextViewAutocompletionController?
	
	func instantiateAutocompletionController() -> CodeTextViewAutocompletionController {
		return	RustAutocompletion.WindowController()
	}
	
	override func complete(sender: AnyObject?) {
		if autocompletionC == nil {
			autocompletionC	=	instantiateAutocompletionController()
			autocompletionC!.presentForSelectionOfTextView(self)
		} else {
			autocompletionC!.dismiss()
			autocompletionC	=	nil
		}
	}
	override func keyDown(theEvent: NSEvent) {
		if let wc1 = autocompletionC {
			let	s	=	theEvent.charactersIgnoringModifiers!
			let	s1	=	s.unicodeScalars
			let	s2	=	s1[s1.startIndex].value
			let	s3	=	Int(s2)
			switch s3 {
			case NSUpArrowFunctionKey:
				wc1.navigateUp()
				return
			case NSDownArrowFunctionKey:
				wc1.navigateDown()
				return
			default:
				break
			}
		}
		super.keyDown(theEvent)
	}
}


protocol CodeTextViewAutocompletionController {
	func presentForSelectionOfTextView(textView:NSTextView)
	func dismiss()
	func navigateUp()
	func navigateDown()
}
	
	

























///	MARK:

extension CodeEditingViewController {
	
	///	I/O can fail at anytime.
	private func _tryLoadingContentOfFileAtURL(u:NSURL) -> Bool {
		assert(NSFileManager.defaultManager().fileExistsAtPath(u.path!))
		
		var	e1	=	nil as NSError?
		let	s1	=	NSString(contentsOfURL: u, encoding: NSUTF8StringEncoding, error: &e1)
		if let s2 = s1 {
			self.codeTextViewController.codeTextView.editable	=	true
			self.codeTextViewController.codeTextView.string		=	s2
			return	true
		} else {
			self.codeTextViewController.codeTextView.editable	=	false
			self.codeTextViewController.codeTextView.string		=	e1!.localizedDescription
			return	false
		}
	}
	
	///	I/O can fail at anytime.
	private func _trySavingContentInPlace() -> Bool {
		Debug.log(URLRepresentation)
		assert(URLRepresentation != nil)
		assert(NSFileManager.defaultManager().fileExistsAtPath(URLRepresentation!.path!))
		
		let	s1	=	self.codeTextViewController.codeTextView.string!
		var	e1	=	nil as NSError?
		let	ok1	=	s1.writeToURL(URLRepresentation!, atomically: true, encoding: NSUTF8StringEncoding, error: &e1)
		Debug.log("Code document saved.")
		
		if !ok1 {
			NSAlert(error: e1!).runModal()
		}
		
		return	ok1
	}
	private func _clearContent() {
		self.codeTextViewController.codeTextView.string		=	""
		self.codeTextViewController.codeTextView.editable	=	false
	}
}

























///	MARK:

extension CodeEditingViewController: NSTextViewDelegate {
	func textView(textView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String) -> Bool {
		if contains(triggerSuffixes(), replacementString) {
//			textView.insertCompletion("AAA", forPartialWordRange: affectedCharRange, movement: NSWritingDirectionNatural, isFinal: false)
//			textView.complete(self)
		}
		return	true
	}
//	func textView(textView: NSTextView, completions words: [AnyObject], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [AnyObject] {
//		Debug.log(words)
//		Debug.log(NSStringFromRange(charRange))
//		index.memory	=	1
//		let	ms	=	RacerExecutionController().resolve("std::")
//		let	ss	=	ms.map({ a in return a.matchString }) as [String]
//		return	ss as [AnyObject]
//	}
	
	private func triggerAutocompletion() {
		
	}
}

private func triggerSuffixes() -> [String] {
	return	[
		"::",
		".",
		"(",
		"-> ",
		":",
	]
}











let NSWritingDirectionNatural	=	-1

