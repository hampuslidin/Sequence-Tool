//
//  MainTableController.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

import Cocoa
import Sequences

class MainTableController: NSViewController,
    NSTableViewDelegate, NSTableViewDataSource {
  // MARK: - Properties
  @IBOutlet var output: NSTextView!
  @IBOutlet var startIndex: NSTextField!
  @IBOutlet var length: NSTextField!
  @IBOutlet var graphView: SequenceGraph!
  fileprivate var sequence: IntegerS? {
    didSet {
      updateGraphAndOutput()
    }
  }
  
  // MARK: - Instance Methods
  func numberOfRows(in tableView: NSTableView) -> Int {
    return SEQS.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?,
      row: Int) -> NSView? {
    let id = tableColumn!.identifier
    let res = tableView.make(withIdentifier: id, owner: self) as! NSTableCellView
    if id == "sequenceTag" {
      res.textField?.stringValue = String(format: "%02X", SEQS[row].tag)
    } else {
      res.textField?.stringValue = SEQS[row].description
    }
    return res
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    let tableView = notification.object as! NSTableView
    sequence = SEQS[tableView.selectedRow]
  }
  
  fileprivate func updateGraphAndOutput() {
    if let defSeq = sequence {
      output!.string = ""
      var i = Int(startIndex.intValue)
      while i < Int(startIndex.intValue) + Int(length.intValue) {
        output!.string = output!.string! + "\(defSeq[i]), "
        i += 1
      }
      output.string = output!.string! + "\(defSeq[i])"
      graphView.seq_ind_amt = (defSeq, Int(startIndex.intValue),
        Int(length.intValue))
      graphView.display()
    }
  }
  
  @IBAction func boundsDidChange(_ sender: AnyObject) {
    updateGraphAndOutput()
  }
}
