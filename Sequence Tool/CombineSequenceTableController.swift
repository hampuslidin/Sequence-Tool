//
//  CombineSequenceTableController.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

import Cocoa
import Sequences

class CombineSequenceTableController: NSViewController,
    NSTableViewDelegate, NSTableViewDataSource {
  // MARK: - Properties
  var variables: [Int: String] {
    var res: [Int: String] = [:]
    for i in 0 ..< SEQS.count {
      res[i] = ""
      if (i+1) > 26 {
        res[i] = res[i/26-1]
      }
      res[i]!.append(codeToAlpha((i+1)%26))
    }
    return res
  }
  
  // MARK: - Instance Methods
  func numberOfRows(in tableView: NSTableView) -> Int {
    return SEQS.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?,
      row: Int) -> NSView? {
    let id = tableColumn!.identifier
    let res = tableView.make(withIdentifier: id, owner: self) as! NSTableCellView
    if id == "sequenceVariable" {
      res.textField?.stringValue = String(variables[row]!)
    } else {
      res.textField?.stringValue = String(format: "%02X", SEQS[row].tag)
    }
    return res
  }
}
