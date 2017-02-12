//
//  NumberField.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

import Cocoa

class NumberField: NSTextField {
  // MARK: - Properties
  override var intValue: Int32 {
    get {
      if stringValue.isEmpty {
        return Int32(placeholderString!)!
      } else {
        return Int32(stringValue)!
      }
    }
    set { super.intValue = newValue }
  }
  
  // MARK: - Instance methods
  override func textDidChange(_ notification: Notification) {
    super.textDidChange(notification)
    
    let textView = notification.object as! NSTextView
    let text: String! = textView.string
    let lastIndex = text.characters.count-1
    if !text.isEmpty {
      let (b, i) = text.isNumeric()
      if !b {
        let index = text.index(text.startIndex, offsetBy: i!)
        let _lastIndex = text.index(text.startIndex, offsetBy: lastIndex)
        textView.string = text[text.startIndex..<index] +
          (index != _lastIndex ? text[text.index(index, offsetBy: 1)..._lastIndex] : "")
      }
      if textView.string!.characters.count >= 5 {
        let index = text.index(text.startIndex, offsetBy: 4)
        textView.string = textView.string![text.startIndex...index]
      }
    }
  }
}
