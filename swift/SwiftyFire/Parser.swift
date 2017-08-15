//
//  Parser.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-11.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

class Parser {
    enum ParserError: Error {
        case noTokens
        case invalidToken(ofKind: Kind, expected: [Kind])
        case invalidValue(_: String)
    }
    
    var topLevelNode: JSONValueNode = JSONValueNode()
    
    private func getNextToken(from tokens: [Token]) throws -> Token {
        if let first = tokens.first {
            return first
        } else {
            throw ParserError.noTokens
        }
    }
    
    private func requireNextTokenOfKind(_ kind: Kind, from tokens: [Token], with additionalExpected: [Kind] = []) throws {
        try self.requireNextTokenOfKinds([kind], from: tokens)
    }
    
    private func requireNextTokenOfKinds(_ kinds: [Kind], from tokens: [Token]) throws {
        let token: Token
        try token = self.getNextToken(from: tokens)
        
        var matches = false
        for kind in kinds {
            if token.kind == kind {
                matches = true
                break
            }
        }
        
        guard matches else {
            throw ParserError.invalidToken(ofKind: token.kind, expected: kinds)
        }
    }
    
    func parse(tokens: [Token]) throws {
        var tokens = tokens
        do {
            try self.topLevelNode = parseValue(from: &tokens)
        } catch {
            throw error
        }
    }
    
    private func parseValue(from tokens: inout [Token]) throws -> JSONValueNode {
        var value = JSONValueNode()
        do {
            if let first = tokens.first {
                switch first.kind {
                case .lbrace:
                    try value = self.parseObject(from: &tokens)
                case .lbrack:
                    try value = self.parseArray(from: &tokens)
                case .quote:
                    try value = self.parseString(from: &tokens)
                case .dash, .numberLiteral:
                    try value = self.parseNumber(from: &tokens)
                case .trueLiteral, .falseLiteral:
                    try value = self.parseBool(from: &tokens)
                case .nullLiteral:
                    try value = self.parseNull(from: &tokens)
                default:
                    throw ParserError.invalidToken(ofKind: first.kind, expected: [.lbrace, .lbrack, .quote, .dash, .numberLiteral, .trueLiteral, .falseLiteral, .nullLiteral])
                }
            } else {
                throw ParserError.noTokens
            }
        } catch {
            throw error
        }
        return value
    }
    
    private func parseObject(from tokens: inout [Token]) throws -> JSONObjectNode {
        let object = JSONObjectNode()
        
        try self.requireNextTokenOfKind(.lbrace, from: tokens)
        
        tokens.removeFirst()
        
        while let first = tokens.first, first.kind != .rbrace {
            if object.children.count > 0 {
                try self.requireNextTokenOfKind(.comma, from: tokens)
                
                tokens.removeFirst()
            }
            
            let string: JSONStringNode
            try string = self.parseString(from: &tokens)
            
            try self.requireNextTokenOfKind(.colon, from: tokens)
            
            tokens.removeFirst()
            
            let value: JSONValueNode
            try value = self.parseValue(from: &tokens)
            object.children[string.value] = value
        }
        
        try self.requireNextTokenOfKind(.rbrace, from: tokens)
        
        tokens.removeFirst()
        
        return object
    }
    
    private func parseArray(from tokens: inout [Token]) throws -> JSONArrayNode {
        let array = JSONArrayNode()
        
        try self.requireNextTokenOfKind(.lbrack, from: tokens)
        
        tokens.removeFirst()
        
        while let first = tokens.first, first.kind != .rbrack {
            if array.elements.count > 0 {
                try self.requireNextTokenOfKind(.comma, from: tokens)
                
                tokens.removeFirst()
            }
            
            let value: JSONValueNode
            try value = self.parseValue(from: &tokens)
            array.elements.append(value)
        }
        
        try self.requireNextTokenOfKind(.rbrack, from: tokens)
        
        tokens.removeFirst()
        
        return array
    }
    
    private func parseNumber(from tokens: inout [Token]) throws -> JSONNumberNode {
        let number = JSONNumberNode()
        
        var token: Token
        
        token = try self.getNextToken(from: tokens)
        
        var isNegative = false
        if token.kind == .dash {
            isNegative = true
            tokens.removeFirst()
        }
        
        try self.requireNextTokenOfKinds([.zero, .numberLiteral], from: tokens)
        
        token = try self.getNextToken(from: tokens)
        
        guard let whole = Double(token.string) else {
            throw ParserError.invalidValue(token.string)
        }
        number.value = whole
        
        tokens.removeFirst()
        
        token = try self.getNextToken(from: tokens)
        
        if token.kind == .dot {
            tokens.removeFirst()
            
            try self.requireNextTokenOfKind(.numberLiteral, from: tokens)
            
            token = try self.getNextToken(from: tokens)
            
            guard let fraction = Double(token.string) else {
                throw ParserError.invalidValue(token.string)
            }
            number.value += fraction * pow(10, -Double(token.string.characters.count))
            
            tokens.removeFirst()
        }
        
        token = try self.getNextToken(from: tokens)
        
        if isNegative {
            number.value *= -1
        }
        
        if token.kind == .e {
            tokens.removeFirst()
            
            token = try self.getNextToken(from: tokens)
            
            var isNegativeExponent = false
            if token.kind == .dash {
                isNegativeExponent = true
                tokens.removeFirst()
            } else if token.kind == .plus {
                tokens.removeFirst()
            }
            
            token = try self.getNextToken(from: tokens)
            
            try self.requireNextTokenOfKind(.numberLiteral, from: tokens)
            
            guard let exponent = Double(token.string) else {
                throw ParserError.invalidValue(token.string)
            }
            number.value *= pow(10, isNegativeExponent ? -exponent : exponent)
            
            tokens.removeFirst()
        }
        
        return number
    }
    
    private func parseString(from tokens: inout [Token]) throws -> JSONStringNode {
        let string = JSONStringNode()
        
        try self.requireNextTokenOfKind(.quote, from: tokens)
        
        tokens.removeFirst()
        
        while let first = tokens.first, first.kind != .quote {
            string.value += first.string
            
            tokens.removeFirst()
        }
        
        try self.requireNextTokenOfKind(.quote, from: tokens)
        
        tokens.removeFirst()
        
        return string
    }
    
    private func parseBool(from tokens: inout [Token]) throws -> JSONBoolNode {
        let bool = JSONBoolNode()
        
        var token: Token
        
        try self.requireNextTokenOfKinds([.trueLiteral, .falseLiteral], from: tokens)
        
        token = try getNextToken(from: tokens)
        
        if token.kind == .trueLiteral {
            bool.value = true
        } else {
            bool.value = false
        }
        
        tokens.removeFirst()
        
        return bool
    }
    
    private func parseNull(from tokens: inout [Token]) throws -> JSONNullNode {
        let null = JSONNullNode()
        
        try self.requireNextTokenOfKind(.nullLiteral, from: tokens)
        
        tokens.removeFirst()
        
        return null
    }
}
