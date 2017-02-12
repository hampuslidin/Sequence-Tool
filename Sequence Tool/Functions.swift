//
//  Functions.swift
//  Sequence Tool
//
//  Author: Hampus Lidin
//

func alphaToCode(_ c: Character) -> Int {
  var res = 0
  switch c {
    case "a": res = 1
    case "b": res = 2
    case "c": res = 3
    case "d": res = 4
    case "e": res = 5
    case "f": res = 6
    case "g": res = 7
    case "h": res = 8
    case "i": res = 9
    case "j": res = 10
    case "k": res = 11
    case "l": res = 12
    case "m": res = 13
    case "n": res = 14
    case "o": res = 15
    case "p": res = 16
    case "q": res = 17
    case "r": res = 18
    case "s": res = 19
    case "t": res = 20
    case "u": res = 21
    case "v": res = 22
    case "w": res = 23
    case "x": res = 24
    case "y": res = 25
    case "z": res = 26
    default:  res = 0
  }
  return res
}
  
func codeToAlpha(_ x: Int) -> Character {
  var res: Character = "a"
  switch x {
    case 1:  res = "a"
    case 2:  res = "b"
    case 3:  res = "c"
    case 4:  res = "d"
    case 5:  res = "e"
    case 6:  res = "f"
    case 7:  res = "g"
    case 8:  res = "h"
    case 9:  res = "i"
    case 10: res = "j"
    case 11: res = "k"
    case 12: res = "l"
    case 13: res = "m"
    case 14: res = "n"
    case 15: res = "o"
    case 16: res = "p"
    case 17: res = "q"
    case 18: res = "r"
    case 19: res = "s"
    case 20: res = "t"
    case 21: res = "u"
    case 22: res = "v"
    case 23: res = "w"
    case 24: res = "x"
    case 25: res = "y"
    case 26: res = "z"
    default: res = "."
  }
  return res
}
