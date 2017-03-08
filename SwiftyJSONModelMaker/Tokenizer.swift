//
//  Tokenizer.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-05.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

enum Kind {
    case none
    case oneCharSym
    case lbrace
    case rbrace
    case lbrack
    case rbrack
    case colon
    case comma
    case dot
    case dash
    case plus
    case e
    case whiteSpace
    case stringLiteral
    case escape
    case numberLiteral
    case trueLiteral
    case falseLiteral
    case nullLiteral
}

enum State {
    case start
    case whiteSpace
    case oneCharSym
    case backslash
    case escape
    case u
    case unicode1
    case unicode2
    case unicode3
    case unicode4
    case string
    case zero
    case number
}

struct StateMap {
    var start: State
    var char: String
    var end: State
    
    init(_ start: State, _ char: String, _ end: State) {
        self.start = start
        self.char = char
        self.end = end
    }
}

class Token {
    var kind: Kind
    var string: String
    
    init(kind: Kind, string: String) {
        self.kind = kind
        self.string = string
        
        if self.kind == .stringLiteral {
            switch string {
            case "true":
                self.kind = .trueLiteral
            case "false":
                self.kind = .falseLiteral
            case "null":
                self.kind = .nullLiteral
            case "e", "E":
                self.kind = .e
            default:
                break
            }
        } else if self.kind == .oneCharSym {
            switch string {
            case "{":
                self.kind = .lbrace
            case "}":
                self.kind = .rbrace
            case "[":
                self.kind = .lbrack
            case "]":
                self.kind = .rbrack
            case ":":
                self.kind = .colon
            case ",":
                self.kind = .comma
            case ".":
                self.kind = .dot
            case "-":
                self.kind = .dash
            case "+":
                self.kind = .plus
            default:
                break
            }
        }
    }
}

class Tokenizer {
    var tokens: [Token]
    var transitions: [StateMap]
    
    init() {
        self.transitions = Array<StateMap>()
        let oneCharSyms: [String] = ["{", "}", "[", "]", ":", ",", "-", "+"]
        for char in oneCharSyms {
            self.transitions.append(StateMap(.start, char, .oneCharSym))
        }
        
        self.transitions.append(StateMap(.start, "\\", .backslash))
        let escapes: [String] = ["\"", "\\", "/", "b", "f", "n", "r", "t"]
        for char in escapes {
            self.transitions.append(StateMap(.backslash, char, .escape))
        }
        self.transitions.append(StateMap(.backslash, "u", .u))
        
        let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        for char in digits {
            self.transitions.append(StateMap(.number, char, .number))
            self.transitions.append(StateMap(.u, char, .unicode1))
            self.transitions.append(StateMap(.unicode1, char, .unicode2))
            self.transitions.append(StateMap(.unicode2, char, .unicode3))
            self.transitions.append(StateMap(.unicode3, char, .unicode4))
        }
        
        let nonZeroDigits = digits.dropFirst()
        for char in nonZeroDigits {
            self.transitions.append(StateMap(.start, char, .number))
        }
        self.transitions.append(StateMap(.start, "0", .zero))
        
        
        
        let letters: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        for char in letters {
            self.transitions.append(StateMap(.start, char, .string))
            self.transitions.append(StateMap(.string, char, .string))
        }
    }
    
    func parseInput(_ input: String) {
        let currentIndex = input.startIndex
        
    }
}
