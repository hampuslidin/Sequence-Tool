//
//  Extensions.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

extension String {
//  subscript(i: Int) -> Character {
//    return self[advance(self.startIndex, i)]
//  }
//  
//  subscript(i: Int) -> String {
//    return String(self[i])
//  }
//  
//  subscript(r: Range<Int>) -> String {
//    return substring(with: (advance(startIndex, r.lowerBound) ..< advance(startIndex, r.upperBound)))
//  }
  
  func isNumeric() -> (Bool, Int?) {
    for i in 0 ..< self.characters.count {
      let index = self.index(startIndex, offsetBy: i)
      switch String(self[index]) {
        case "0": continue
        case "1": continue
        case "2": continue
        case "3": continue
        case "4": continue
        case "5": continue
        case "6": continue
        case "7": continue
        case "8": continue
        case "9": continue
        default:  return (false, i)
      }
    }
    return (true, nil)
  }
  
  func isAlpha() -> (Bool, Int?) {
    for i in 0 ..< self.characters.count {
      let index = self.index(startIndex, offsetBy: i)
      if alphaToCode(self[index]) == 0 { return (false, i) }
    }
    return (true, nil)
  }
  
  mutating func filter(_ condition: (Character) -> Bool) {
    var res = ""
    for c in self.characters {
      if condition(c) {
        res.append(c)
      }
    }
    self = res
  }
  
  mutating func filterSubString(_ subString: String, condition: (String, String) -> Bool) {
    let stringLength = subString.characters.count
    if stringLength == 0 { return }
    
    var res = ""
    for var i in 0 ..< self.characters.count {
      let index = self.index(startIndex, offsetBy: i)
      if i > self.characters.count-stringLength ||
          condition(subString, self[index ..< self.index(index, offsetBy: stringLength)]) {
        res.append(self[index])
      } else {
        i += stringLength-1
      }
    }
    self = res
  }
}
