//
//  AppDelegate.swift
//  Sequence Tool
//
//  Created by Hampus Lidin on 2015-06-08.
//  Copyright (c) 2015 Lidin. All rights reserved.
//

import Cocoa
import Sequences

let SEQS: [IntegerS] = [
  A000002(),
  A000027(),
  A000040(),
  A000045(),
  A001057(),
  A001477(),
  A004718(),
  A056239(),
  A121805(),
  A181391(),
  A244471()
]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var graphWindow: NSWindow!
  @IBOutlet weak var expressionWindow: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func windowShouldClose(_ sender: Any) -> Bool {
    if graphWindow.isVisible || expressionWindow.isVisible {
      let alert = NSAlert()
      alert.addButton(withTitle: "Quit")
      alert.addButton(withTitle: "Cancel")
      alert.messageText = "Quiting application"
      alert.informativeText = "Are you sure you want to quit?"
      alert.alertStyle = .warning
      if alert.runModal() == NSAlertFirstButtonReturn {
        NSApplication.shared().terminate(self)
        return true
      }
      return false
    }
    NSApplication.shared().terminate(self)
    return true
  }
}

