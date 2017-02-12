//
//  ExpressionParser.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

import Cocoa
import Sequences

class ExpressionParser: NSTextField {
  // MARK: - Outlets
  @IBOutlet var errorLabel: NSTextField!
  @IBOutlet var variableController: CombineSequenceTableController!
  @IBOutlet var graph: SequenceGraph!
  @IBOutlet var startIndex: NumberField!
  @IBOutlet var length: NumberField!
  var sequence: IntegerS? = nil {
    didSet {
      if self.sequence != nil {
        graph.seq_ind_amt = (self.sequence!, Int(startIndex.intValue),
          Int(length.intValue))
        graph.display()
      }
    }
  }

  // MARK: - Class methods
  static func isOperator(_ char: Character) -> Bool {
    switch char {
      case "+":   break
      case "-":   break
      case "*":   break
      case "/":   break
      case "%":   break
      case "&":   break
      case "|":   break
      case "^":   break
      case "~":   break
      default:    return false
    }
    return true
  }
  
  // MARK: - Instance methods
  override func textDidChange(_ notification: Notification) {
    super.textDidChange(notification)
    stringValue = stringValue.lowercased()
    errorLabel.stringValue = ""
  }
  
  override func textDidEndEditing(_ notification: Notification) {
    super.textDidEndEditing(notification)
    if let sequence = parseExpression() {
      self.sequence = sequence
    } else {
      self.sequence = nil
    }
  }
  
  override func mouseMoved(with theEvent: NSEvent) {
    super.mouseMoved(with: theEvent)
    
    var res = ""
    if let defSeq = sequence {
      for e in defSeq[0 ..< 10] {
        res += "\(e), "
      }
      toolTip = res + "..."
    } else {
      toolTip = "Invalid expression."
    }
  }
  
  fileprivate func parseExpression() -> CombinedS? {
    let (possibleExpression, errorMessage) = breakUpExpression()
    if var expression = possibleExpression {
      var partResults: [CombinedS] = []
      var bracketIndices = [Int]()
      // Reduce brackets
      for var i in 0 ..< expression.count {
        let e = expression[i]
        if e == "(" {
          bracketIndices.append(i)
        }
        
        else if e == ")" {
          if let lastIndex = bracketIndices.last {
            var partExpr = [String]()
            for j in  (lastIndex+1) ..< i { partExpr.append(expression[j]) }
            let partExprCount = partExpr.count
            if let errorMessage =
                performOperations(&partExpr, partResults: &partResults) {
              errorLabel.stringValue = "Invalid expression. \(errorMessage)"
              return nil
            }
            expression[i] = partExpr.first!
            expression.removeSubrange((lastIndex ..< i))
            i -= partExprCount+1
            bracketIndices.removeLast()
          } else {
            errorLabel.stringValue = "Invalid expression. Mismatched brackets."
            return nil
          }
        }
      }
    
      // When brackets have been reduced, perform remaining operations
      if let errorMessage = performOperations(&expression, partResults: &partResults) {
        errorLabel.stringValue = "Invalid expression. \(errorMessage)"
        return nil
      }
      
      return partResults.first!
    } else {
      errorLabel.stringValue = "Invalid expression. \(errorMessage)"
      return nil
    }
  }
  
  fileprivate func breakUpExpression() -> ([String]?, errorMessage: String) {
    var previousSymbolWasArgument = false
    
    // Remove invalid characters
    stringValue.filter() { (c: Character) -> Bool in
      return String(c).isNumeric().0 || String(c).isAlpha().0 ||
        ExpressionParser.isOperator(c) || c == "(" || c == ")" || c == ">" || c == "<"
    }
    
    var res: [String] = []
    var i = stringValue.startIndex
    while i < stringValue.endIndex {
      let symbol = String(stringValue[i])
      var fullOperand = symbol
      var ik = stringValue.index(i, offsetBy: 1)
      
      if symbol == "(" {
        if previousSymbolWasArgument {
          res.append("*")
        }
        previousSymbolWasArgument = false
        res.append(symbol)
      }
      
      else if symbol == ")"{
        previousSymbolWasArgument = true
        res.append(symbol)
      }
      
      else if ExpressionParser.isOperator(symbol.characters.first!) {
        previousSymbolWasArgument = false
        res.append(symbol)
      }
      
      else if symbol == "<" || symbol == ">" {
        previousSymbolWasArgument = false
        let nextChar = String(stringValue[stringValue.index(i, offsetBy: 1)])
        if i < stringValue.index(stringValue.endIndex, offsetBy: -1) &&
            (nextChar == "<" || nextChar == ">") &&
            symbol == nextChar {
          res.append("\(symbol)\(symbol)")
          i = stringValue.index(i, offsetBy: 1)
        } else {
          return (nil, "Shift operator is typed incorrectly.")
        }
      }
      
      else if symbol.isAlpha().0 {
        if previousSymbolWasArgument {
          res.append("*")
        }
        previousSymbolWasArgument = true
        while ik < stringValue.endIndex &&
            String(stringValue[ik]).isAlpha().0 {
          fullOperand += String(stringValue[ik])
          ik = stringValue.index(ik, offsetBy: 1)
        }
        var found = false
        for (_,variable) in variableController.variables {
          if variable == fullOperand {
            found = true
            break
          }
        }
        if !found {
          return (nil, "There is no variable called \'\(fullOperand)\'.")
        }
        i = stringValue.index(ik, offsetBy: -1)
        res.append(fullOperand)
      }
      
      else if symbol.isNumeric().0 {
        if previousSymbolWasArgument {
          res.append("*")
        }
        previousSymbolWasArgument = true
        while ik < stringValue.endIndex &&
            String(stringValue[ik]).isNumeric().0 {
          fullOperand += String(stringValue[ik])
          ik = stringValue.index(ik, offsetBy: 1)
        }
        i = stringValue.index(ik, offsetBy: -1)
        res.append(fullOperand)
      }
      i = stringValue.index(i, offsetBy: 1)
    }
    return (res, "No errors.")
  }
  
  fileprivate func performOperations(_ expression: inout [String],
      partResults: inout [CombinedS]) -> String? {
    // Check for empty expression.
    if expression.isEmpty {
      return "Expression is empty."
    }
    
    // Check if expression contains a single literal or variable.
    if expression.count == 1 {
      if expression[0].isAlpha().0 {
        partResults.append(CombinedS(seq: findVariable(expression[0])!))
        expression = ["#\(partResults.count-1)"]
        return nil
      }
      if expression[0].isNumeric().0 {
        partResults.append(CombinedS(integerLiteral: Int(expression[0])!))
        expression = ["#\(partResults.count-1)"]
        return nil
      }
    }
    
    // Perform unary operations
    for i in 0 ..< expression.count {
      let e = expression[i]
      
      // Check if the prefix operator '-' is in fact a subrtaction.
      if e == "-" && i-1 >= 0 && (!ExpressionParser.isOperator(expression[i-1]["".startIndex]) ||
          expression[i-1] == ")") {
        continue
      }
      
      // Check if left-hand side argument has a potential prefix operator.
      if e == "-" || e == "~" {
        
        // Check if there is an element to the right of the potential prefix operator.
        if i+1 < expression.count {
          
          // Calculate the argument.
          var arg: CombinedS
          var smallestIndex = partResults.count
          if expression[i+1].isAlpha().0 {
            arg = unaryOperator(findVariable(expression[i+1])!, opName: e)
          } else if expression[i+1].isNumeric().0 {
            arg = unaryOperator(RecurringS(Int(expression[i+1])!), opName: e)
          } else if expression[i+1]["".startIndex] == "#" {
            let expr = expression[i+1]
            let lower = expr.index(expr.startIndex, offsetBy: 1)
            smallestIndex = Int(expr[lower ..< expr.endIndex])!
            arg = unaryOperator(partResults[smallestIndex], opName: e)
          } else {
            return "Bad arguments for prefix operator \'\(e)\'."
          }
          
          // Store the results in `partResults`.
          if smallestIndex == partResults.count {
            partResults.append(arg)
          } else {
            partResults[smallestIndex] = arg
          }
          
          // Update the expression
          expression[i] = "#\(smallestIndex)"
          expression.remove(at: i+1)

        } else { return "Bad arguments for operator \'\(e)\'." }
      }
    }
    
    // Perform shift operations.
    for var i in 0 ..< expression.count {
      let e = expression[i]
      if e == "<<" || e == ">>" {
        if i+2 < expression.count {
          if expression[i+2] == "<<" || expression[i+2] == ">>" {
            return "Shift-operators are non-associative."
          }
        }
        if i+3 < expression.count {
          if expression[i+1] != "(" &&
              expression[i+3] == "<<" || expression[i+3] == ">>" {
            return "Shift-operators are non-associative."
          }
        }
        if let errorMessage =
            operate(i, expression: &expression, partResults: &partResults) {
          if errorMessage != "bracket" {
            return errorMessage
          }
        } else { i -= 1 }
      }
    }
      
    // Perform multiplications, divisions, modulo operations and bitwise ANDs.
    var i = 0
    while i < expression.count {
      let e = expression[i]
      if e == "*" || e == "/" || e == "%" || e == "&" {
        if let errorMessage =
            operate(i, expression: &expression, partResults: &partResults) {
          if errorMessage != "bracket" {
            return errorMessage
          }
        } else { i -= 1 }
      }
      i += 1
    }
      
    // Perform additions, subtractions, bitwise ORs and bitwise XORs.
    i = 0
    while i < expression.count {
      let e = expression[i]
      if e == "+" || e == "-" || e == "|" || e == "^" {
        if let errorMessage =
            operate(i, expression: &expression, partResults: &partResults) {
          if errorMessage != "bracket" {
            return errorMessage
          }
        } else { i -= 1 }
      }
      i += 1
    }
    
    return nil
  }
  
  fileprivate func operate(_ index: Int, expression: inout [String],
      partResults: inout [CombinedS]) -> String? {
    enum ArgType { case alpha, numeric, unaryOp, partRes, bracket, invalid }
    
    if index > 0 && index < expression.count-1 {
      let lhs = expression[index-1], rhs = expression[index+1]
      
      // Check if operands are brackets.
      if lhs == ")" || rhs == "(" { return "bracket" }
      
      // Check if operands are valid.
      var lhsArg = IntegerS(), rhsArg = IntegerS()
      if lhs.isAlpha().0 {
        lhsArg = findVariable(lhs)!
      }
      else if lhs.isNumeric().0 {
        lhsArg = RecurringS(Int(lhs)!)
      }
      else if lhs[lhs.startIndex] == "#" {
        lhsArg = partResults[Int(lhs[lhs.index(lhs.startIndex, offsetBy: 1)..<lhs.endIndex])!]
      }
      
      if rhs.isAlpha().0 {
        rhsArg = findVariable(rhs)!
      }
      else if rhs.isNumeric().0 {
        rhsArg = RecurringS(Int(rhs)!)
      }
      else if rhs[rhs.startIndex] == "#" {
        rhsArg = partResults[Int(rhs[rhs.index(rhs.startIndex, offsetBy: 1)..<rhs.endIndex])!]
      }
      
      // Append the result to `partResults`
      let result = binaryOperator(lhsArg, rhs: rhsArg, opName: expression[index])!
      var smallestIndex = partResults.count
      if lhs[lhs.startIndex] == "#" {
        let t = Int(lhs[lhs.index(lhs.startIndex, offsetBy: 1) ..< lhs.endIndex])!
        smallestIndex = t < smallestIndex ? t : smallestIndex
      }
      if rhs[rhs.startIndex] == "#" {
        let t = Int(rhs[rhs.index(rhs.startIndex, offsetBy: 1) ..< rhs.endIndex])!
        smallestIndex = t < smallestIndex ? t : smallestIndex
      }
      if smallestIndex == partResults.count {
        partResults.append(result)
      } else {
        partResults[smallestIndex] = result
      }
      
      // Remove the operator and operands from the expression
      expression[index+1] = "#\(smallestIndex)"
      expression.removeSubrange(((index-1) ..< index+1))
      return nil
    }
    
    return "Bad arguments for operator '\(expression[index])'."
  }
  
  fileprivate func findVariable(_ name: String) -> IntegerS? {
    for (i, v) in variableController.variables {
      if v == name { return SEQS[i] }
    }
    return nil
  }
  
  fileprivate func unaryOperator(_ operand: IntegerS, opName: String) -> CombinedS {
    if opName ==  "-" { return -operand }
    return ~operand
  }
  
  fileprivate func binaryOperator(_ lhs: IntegerS, rhs: IntegerS, opName: String)
      -> CombinedS? {
    switch opName {
      case "+":
        return lhs+rhs
      case "-":
        return lhs-rhs
      case "*":
        return lhs*rhs
      case "/":
        return lhs/rhs
      case "%":
        return lhs%rhs
      case "<<":
        return lhs<<rhs
      case ">>":
        return lhs>>rhs
      case "&":
        return lhs&rhs
      case "|":
        return lhs|rhs
      case "^":
        return lhs^rhs
      default:
        return nil
    }
  }
}
