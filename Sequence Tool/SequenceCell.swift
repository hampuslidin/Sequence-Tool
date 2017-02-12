//
//  SequenceCell.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

import Cocoa

class SequenceCell: NSTableCellView {
  // MARK: - Properties
  @IBOutlet weak var tableViewController: NSViewController!

  // MARK: - Instance methods
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    
    addTrackingArea(NSTrackingArea(rect: bounds,
                                   options: [.mouseMoved, .activeInKeyWindow],
                                   owner: self,
                                   userInfo: nil))
  }
  
  override func mouseMoved(with theEvent: NSEvent) {
    super.mouseMoved(with: theEvent)
    
    let location = theEvent.locationInWindow
    let tableLocation = tableViewController.view.convert(location, from: nil)
    let rowEntered = (tableViewController.view as! NSTableView).row(at: tableLocation)
    if rowEntered < 0 || rowEntered >= SEQS.count { return }
    
    var res = ""
    for e in SEQS[rowEntered][0 ..< 10] {
      res += "\(e), "
    }
    toolTip = res + "..."
  }
}
