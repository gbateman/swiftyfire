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
    case quote
    case whiteSpace
    case stringLiteral
    case escape
    case numberLiteral
    case trueLiteral
    case falseLiteral
    case nullLiteral
    
    init(_ state: State) {
        switch state {
        case .oneCharSym:
            self = .oneCharSym
        case .escape:
            self = .escape
        case .unicode4:
            self = .escape
        case .string:
            self = .stringLiteral
        case .zero:
            self = .numberLiteral
        case .number:
            self = .numberLiteral
        default:
            self = .none
        }
    }
}

enum State {
    case start
    case error
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

class Token: CustomStringConvertible {
    var kind: Kind
    var string: String
    
    var description: String {
        return "<kind:\(kind),string:\(string)>"
    }
    
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
            case "\"":
                self.kind = .quote
            default:
                break
            }
        }
    }
}

class Tokenizer {
    var tokens: [Token]
    var transitions: [StateMap]
    var illegalStringTransitions: [StateMap]
    
    enum TokenizerError: Error {
        case illegalChar
    }
    
    init() {
        self.tokens = Array<Token>()
        self.transitions = Array<StateMap>()
        self.illegalStringTransitions = Array<StateMap>()
        let oneCharSyms: [String] = ["{", "}", "[", "]", ":", ",", "-", "+", "\""]
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
        
        for u in 0 ... 31 {
            if let scalar = UnicodeScalar(u) {
                let char = String(Character(scalar))
                self.illegalStringTransitions.append(StateMap(.start, char, .error))
                self.illegalStringTransitions.append(StateMap(.string, char, .error))
            }
        }
        for u in 128 ... 159 {
            if let scalar = UnicodeScalar(u) {
                let char = String(Character(scalar))
                self.illegalStringTransitions.append(StateMap(.start, char, .error))
                self.illegalStringTransitions.append(StateMap(.string, char, .error))
            }
        }
        self.transitions.append(StateMap(.string, "\\", .error))
        self.transitions.append(StateMap(.string, "\"", .error))
    }
    
    func parseInput(_ input: String) throws {
        var currentIndex = input.startIndex
        
        var currentString: String = ""
        var currentState: State = .start
        var currentChar: Character = input[currentIndex]
        
        func filter(_ stateMap: StateMap) -> Bool {
            return stateMap.start == currentState && stateMap.char == String(currentChar)
        }
        
        func isControlCharacter() -> Bool {
            return self.illegalStringTransitions.filter(filter).first != nil
        }
        
        func isValidStringTransition() -> Bool {
            return (currentState == .start || currentState == .string)
                && self.illegalStringTransitions.filter(filter).first == nil
        }
        
        guard let eotScalar = UnicodeScalar(4) else { return }
        let eot = Character(eotScalar)
        
        while currentIndex != input.endIndex && input[currentIndex] != eot {
            currentChar = input[currentIndex]
            
            if currentState != .string && String(currentChar).rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil {
                currentIndex = input.index(after: currentIndex)
                continue
            }
            
            if let transition = self.transitions.filter(filter).first {
                if currentState == .string {
                    self.tokens.append(Token(kind: Kind(currentState), string: currentString))
                    currentString = ""
                    currentState = .start
                    continue
                } else {
                    currentString += String(currentChar)
                    currentState = transition.end
                }
            } else if isControlCharacter() {
                throw TokenizerError.illegalChar
            } else if isValidStringTransition() {
                currentString += String(currentChar)
                currentState = .string
            } else {
                self.tokens.append(Token(kind: Kind(currentState), string: currentString))
                currentString = ""
                currentState = .start
                continue
            }
            
            currentIndex = input.index(after: currentIndex)
        }
        // Since the last char never gets checked for transitions
        self.tokens.append(Token(kind: Kind(currentState), string: currentString))
    }
}
