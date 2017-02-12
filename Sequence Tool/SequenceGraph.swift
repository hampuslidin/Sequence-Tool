//
//  SequenceGraph.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

import Cocoa
import Sequences
import LargeNumbers

class SequenceGraph: NSView {
  // MARK: - Properties
  @IBInspectable var axisInset:       CGFloat   = 20.0
  @IBInspectable var limitInset:      CGFloat   = 10.0
  @IBInspectable var limitSize:       CGFloat   = 8.0
  @IBOutlet var gridLines:            NSButton!
  fileprivate var yAxisLimits:            Int       = 4
  fileprivate var xAxisLimits:            Int       = 4
  fileprivate var yAxisInset:             CGFloat? {
    if let defSubSeq = subSeqSorted {
      // yAxisInset
      let numberOffset = 6.8*CGFloat((LInt(defSubSeq.last!)).toString().characters.count)
      let labelOffset = limitSize/2 + 0.7 + numberOffset
      return labelOffset > axisInset ? labelOffset : axisInset
    }
    return nil
  }
  fileprivate var subSeqSorted:           [LInt]? {
    if let (defSeq, defInd, defAmt) = seq_ind_amt {
      var subSeq = defSeq[defInd ..< defInd+defAmt]
      subSeq.sort { $0 < $1 }
      return subSeq
    }
    return nil
  }
  fileprivate var maxXLimit:              Int? {
    if let (_, _, defAmt) = seq_ind_amt {
      // maxXLimit
      return ((defAmt-2)/xAxisLimits+1)*xAxisLimits
    }
    return nil
  }
  fileprivate var maxYLimit:              LInt?
  fileprivate var minYLimit:              LInt?
  var seq_ind_amt:                    (IntegerS, Int, Int)? {
    didSet { updateProperties() }
  }
  
  // MARK: - NSView
  override func draw(_ dirtyRect: NSRect) {
    // Set background color to white
    NSColor.white.set()
    NSBezierPath.fill(dirtyRect)
    
    // Draw axises
    NSColor.black.set()
    drawAxises(dirtyRect)
    
    // Draw limits
    drawLimits(dirtyRect)
    
    // Draw graph
    NSColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 0.85).set()
    drawGraph(dirtyRect)
    
    // Draw labels
    NSColor.black.set()
    drawLabels(dirtyRect)
  }
  
  // MARK: - Helper methods
  fileprivate func drawAxises(_ dirtyRect: NSRect) {
    var axis = NSBezierPath()
    let inset = yAxisInset ?? axisInset
    axis.move(to: NSPoint(x: inset, y: dirtyRect.height-inset))
    axis.line(to: NSPoint(x: inset, y: inset))
    axis.lineWidth = 1.0
    axis.stroke()
    
    // If y-axis range doesn't contain zero, don't draw x-axis.
    if subSeqSorted != nil {
      if minYLimit! > 0 || maxYLimit! < 0 { return }
    }
    axis = NSBezierPath()
    if minYLimit! < 0 {
      let xAxisInset = getXAxisInset(dirtyRect)
      axis.move(to: NSPoint(x: inset, y: xAxisInset))
      axis.line(to: NSPoint(x: dirtyRect.width-inset, y: xAxisInset))
    } else {
      axis.move(to: NSPoint(x: inset, y: inset))
      axis.line(to: NSPoint(x: dirtyRect.width-inset, y: inset))
    }
    axis.lineWidth = 1.0
    axis.stroke()
  }
  
  fileprivate func drawLimits(_ dirtyRect: NSRect) {
    let inset = (yAxisInset ?? axisInset)
    let offsX = (dirtyRect.width-2*inset-limitInset)/CGFloat(xAxisLimits)
    let offsY = (dirtyRect.height-2*inset-limitInset)/CGFloat(yAxisLimits)
    
    var limit: NSBezierPath
    for l in 0 ..< xAxisLimits+1 {
      let i = CGFloat(l)
      let xAxisInset = getXAxisInset(dirtyRect)
      limit = NSBezierPath()
      limit.move(to: NSPoint(x: inset+offsX*i, y: xAxisInset-limitSize/2))
      limit.line(to: NSPoint(x: inset+offsX*i, y: xAxisInset+limitSize/2))
      limit.lineWidth = 1.0
      limit.stroke()
      if gridLines.state == NSOnState {
        let gridLine = NSBezierPath()
        gridLine.move(to: NSPoint(x: inset+offsX*i, y: dirtyRect.height-inset))
        gridLine.line(to: NSPoint(x: inset+offsX*i, y: inset))
        
        NSColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 0.5).set()
        gridLine.setLineDash([2.0, 1.0], count: 2, phase: 0.0)
        gridLine.lineWidth = 0.5
        gridLine.stroke()
        NSColor.black.set()
      }
    }
    
    for l in 0 ..< yAxisLimits+1 {
      let i = CGFloat(l)
      limit = NSBezierPath()
      limit.move(to: NSPoint(x: inset-limitSize/2, y: inset+offsY*i))
      limit.line(to: NSPoint(x: inset+limitSize/2, y: inset+offsY*i))
      limit.lineWidth = 1.0
      limit.stroke()
      if gridLines.state == NSOnState {
        let gridLine = NSBezierPath()
        gridLine.move(to: NSPoint(x: inset, y: inset+offsY*i))
        gridLine.line(to: NSPoint(x: dirtyRect.width-inset, y: inset+offsY*i))
        
        NSColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 0.5).set()
        gridLine.setLineDash([2.0, 1.0], count: 2, phase: 0.0)
        gridLine.lineWidth = 0.5
        gridLine.stroke()
        NSColor.black.set()
      }
    }
  }
  
  fileprivate func drawLabels(_ dirtyRect: NSRect) {
    if let (_, defInd, defAmt) = seq_ind_amt {
      let offsX = (defAmt-2)/xAxisLimits + 1
      let a = maxYLimit!, b = minYLimit!
      let offsY = (maxYLimit!-minYLimit!)/LInt(yAxisLimits)

      let spaceOffsX = (dirtyRect.width-2*yAxisInset!-limitInset)/CGFloat(xAxisLimits)
      let spaceOffsY = (dirtyRect.height-2*yAxisInset!-limitInset)/CGFloat(yAxisLimits)

      let font: NSFont! = NSFont(name: "Helvetica", size: 10.0)
      let attributes = [NSFontAttributeName: font,
                        NSForegroundColorAttributeName: NSColor.black]
      for i in 0 ..< xAxisLimits+1 {
        if defInd+i*(offsX == 0 ? 1 : offsX) == 0 { continue }
        let textXOrigin = NSPoint(x: yAxisInset!+spaceOffsX*CGFloat(i)-4.0,
          y: getXAxisInset(dirtyRect)-limitSize/2-15.0)
        let textX = NSAttributedString(string: String(defInd+i*(offsX == 0 ? 1 : offsX)),
          attributes: attributes)
        textX.draw(at: textXOrigin)
      }
      
      for i in 0 ..< yAxisLimits+1 {
        let labelValue = minYLimit! + LInt(i)*offsY
        if labelValue == 0 { continue }
        let numberOffset =
          6.8*CGFloat(magnitude(labelValue)) + (labelValue < 0 ? 6.8 : 0.0)
        let textYOrigin = NSPoint(
          x: yAxisInset!-limitSize/2-0.7-numberOffset,
          y: yAxisInset!+spaceOffsY*CGFloat(i)-7.0)
        let textY = NSAttributedString(
          string: (minYLimit! + LInt(i)*offsY).toString(),
          attributes: attributes)
        textY.draw(at: textYOrigin)
      }
    }
  }
  
  fileprivate func drawGraph(_ dirtyRect: NSRect) {
    if let (defSeq, defInd, defAmt) = (seq_ind_amt) {
      let offsX = (dirtyRect.width-2*yAxisInset!-limitInset)/CGFloat(maxXLimit!)
      
      let yAxisLength = dirtyRect.height-2*yAxisInset!-limitInset
      let fromRange: Range<LInt> = minYLimit! ..< maxYLimit!
      let toRange:   Range<LInt> = 0 ..< LInt(UInt.max)-1
      let offsY = yAxisLength/CGFloat(UInt.max)
      
      let graph = NSBezierPath()
      var yCoordinate = offsY*CGFloat(transform(defSeq[defInd],
        fromRange: fromRange, toRange: toRange).value[0])
      
      graph.move(to: NSPoint(x: yAxisInset!,
        y: yAxisInset! + yCoordinate))
      for i in 1 ..< defAmt {
        yCoordinate = offsY*CGFloat(transform(defSeq[defInd+i],
          fromRange: fromRange, toRange: toRange).value[0])
        graph.line(to: NSPoint(x: yAxisInset!+offsX*CGFloat(i),
          y: yAxisInset!+yCoordinate))
      }
      
      graph.lineJoinStyle = NSLineJoinStyle.roundLineJoinStyle
      graph.lineWidth = 2.0
      graph.stroke()
    }
  }
  
  fileprivate func getXAxisInset(_ dirtyRect: NSRect) -> CGFloat {
    let inset = yAxisInset ?? axisInset
    let zeroLine = transform(0,
                             fromRange: ((minYLimit ?? 0) ..< (maxYLimit ?? 1)),
                             toRange:   (0 ..< LInt(UInt.max)-1))
    let axisLength = (dirtyRect.height-2*inset-limitInset)
    return inset + CGFloat(zeroLine.value[0])*axisLength/CGFloat(UInt.max-1)
  }
  
  fileprivate func updateProperties() {
    if let (defSeq, _, defAmt) = seq_ind_amt {
      // maxYLimit & minYLimit
      if subSeqSorted!.last! > 0 && subSeqSorted![0] < 0 {
        var d = (subSeqSorted!.last!-subSeqSorted![0]-1)/LInt(yAxisLimits)+1
        var a = subSeqSorted!.last!/d
        var b = abs(subSeqSorted![0])/d
        
        var partsLeft = LInt(yAxisLimits) - a - b
        if partsLeft != 0 {
          let a_b_diff = abs(a-b)
          if partsLeft <= a_b_diff {
            if a > b { b += partsLeft }
            else     { a += partsLeft }
          } else {
            if a > b { b += a_b_diff }
            else     { a += a_b_diff }
            
            partsLeft -= a_b_diff
            a += (partsLeft+1)/2
            b += partsLeft/2
          }
        }
          
        while a*d < subSeqSorted!.last! || -b*d > subSeqSorted![0] {
          d += 1
        }
          
        maxYLimit = a*d
        minYLimit = -b*d
      } else {
        if subSeqSorted!.last! > 0 {
          maxYLimit =
            ((subSeqSorted!.last!-1)/LInt(yAxisLimits)+1)*LInt(yAxisLimits)
          minYLimit = (subSeqSorted![0]-1)/LInt(yAxisLimits)*LInt(yAxisLimits)
        } else {
          maxYLimit = (subSeqSorted!.last!+1)/LInt(yAxisLimits)*LInt(yAxisLimits)
          minYLimit =
            ((subSeqSorted![0]+1)/LInt(yAxisLimits)-1)*LInt(yAxisLimits)
        }
        if subSeqSorted![0] == 0 && subSeqSorted!.last! == 0 {
          maxYLimit = (-minYLimit!+1)/2
          minYLimit = minYLimit!/2
        }
      }
    } else {
      maxYLimit     = nil
      minYLimit     = nil
    }
  }
  
  /**
      Given the number `n` that habitates in the range `fromRange`, this function
      transforms it into the range `toRange`, with integer approximization.
      
      :param: n         The number to transform.
      :param: fromRange The range that `n` habitates in.
      :param: toRange   The new range habitat for `n`.
      
      :returns: `n` transformed from `fromRange` to `toRange`.
  */
  func transform(_ n: LInt, fromRange: Range<LInt>, toRange: Range<LInt>) -> LInt {
    let fromRangeVal  = fromRange.upperBound-fromRange.lowerBound
    let toRangeVal    = toRange.upperBound-toRange.lowerBound
    return (n-fromRange.lowerBound)*toRangeVal/fromRangeVal
  }
  
  /**
      Returns the magnitude of a number.
  */
  func magnitude(_ n: LInt) -> Int {
    var x = n, res = 1
    while x/10 != 0 {
      x /= 10
      res += 1
    }
    return res
  }
  
  // MARK: - Actions
  @IBAction func xAxisStepperDidChange(_ sender: AnyObject) {
    xAxisLimits = (sender as! NSStepper).integerValue
    updateProperties()
    display()
  }
  
  @IBAction func yAxisStepperDidChange(_ sender: AnyObject) {
    yAxisLimits = (sender as! NSStepper).integerValue
    updateProperties()
    display()
  }
  
  @IBAction func gridSwitchDidChange(_: AnyObject) {
    updateProperties()
    display()
  }
}
