//
//  Parser.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-11.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

fileprivate struct StateMap {
    
}

fileprivate enum State {
    
}

class Parser {
    enum ParserError: Error {
        case NoTokens
        case InvalidToken(ofKind: Kind, expected: [Kind])
    }
    
    var topLevelNode: JSONValueNode?
    
    func parse(tokens: [Token]) throws {
        var tokens = tokens
        do {
            if let first = tokens.first {
                switch first.kind {
                case .lbrace:
                    try self.topLevelNode = self.parseObject(from: &tokens)
                case .lbrack:
                    try self.topLevelNode = self.parseArray(from: &tokens)
                case .quote:
                    try self.topLevelNode = self.parseString(from: &tokens)
                case .dash, .numberLiteral:
                    try self.topLevelNode = self.parseNumber(from: &tokens)
                case .trueLiteral, .falseLiteral:
                    try self.topLevelNode = self.parseBool(from: &tokens)
                case .nullLiteral:
                    try self.topLevelNode = self.parseNull(from: &tokens)
                default:
                    throw ParserError.InvalidToken(ofKind: first.kind, expected: [.lbrace, .lbrack, .quote, .dash, .numberLiteral, .trueLiteral, .falseLiteral, .nullLiteral])
                }
            } else {
                throw ParserError.NoTokens
            }
        } catch {
            throw error
        }
    }
    
    func parseObject(from tokens: inout [Token]) throws -> JSONObjectNode {
        let object = JSONObjectNode()
        
        var token: Token
        
        if let first = tokens.first {
            token = first
        } else {
            throw ParserError.NoTokens
        }
        
        guard token.kind == .lbrace else {
            throw ParserError.InvalidToken(ofKind: token.kind, expected: [.quote, .rbrace])
        }
        
        tokens.removeFirst()
        
        while let first = tokens.first, first.kind == .quote {
            var key = ""
            
            tokens.removeFirst()
            
            while let first = tokens.first, first.kind == .stringLiteral || first.kind == .escape {
                token = first
                
                key += token.string
                
                tokens.removeFirst()
            }
            
            if let first = tokens.first {
                token = first
            } else {
                throw ParserError.NoTokens
            }
            
            guard token.kind == .quote else {
                throw ParserError.InvalidToken(ofKind: token.kind, expected: [.quote])
            }
            
            if let first = tokens.first {
                token = first
            } else {
                throw ParserError.NoTokens
            }
            
            guard token.kind == .colon else {
                throw ParserError.InvalidToken(ofKind: token.kind, expected: [.colon])
            }
        }
        
        if let first = tokens.first {
            token = first
        } else {
            throw ParserError.NoTokens
        }
        
        guard token.kind == .rbrace else {
            throw ParserError.InvalidToken(ofKind: token.kind, expected: [.rbrace])
        }
        
        return object
    }
    
    func parseArray(from tokens: inout [Token]) throws -> JSONArrayNode {
        return JSONArrayNode()
    }
    
    func parseNumber(from tokens: inout [Token]) throws -> JSONNumberNode {
        return JSONNumberNode()
    }
    
    func parseString(from tokens: inout [Token]) throws -> JSONStringNode {
        return JSONStringNode()
    }
    
    func parseBool(from tokens: inout [Token]) throws -> JSONBoolNode {
        return JSONBoolNode()
    }
    
    func parseNull(from tokens: inout [Token]) throws -> JSONNullNode {
        return JSONNullNode()
    }
}
