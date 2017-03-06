//
//  JSONValueNode.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-03.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

class JSONValueNode {
    var type: String = ""
    
    func parse(input: String, startIndex: String.Index) -> String.Index? {
        return startIndex
    }
    
    func skipWhitespaces(input: String, startIndex: String.Index) -> String.Index? {
        var currentIndex = startIndex
        while String(input[currentIndex]).rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil {
            currentIndex = input.index(after: currentIndex)
            if currentIndex == input.endIndex {
                return nil
            }
        }
        return currentIndex
    }
}

class JSONObjectNode: JSONValueNode {
    var children: [String: JSONValueNode] = [:]
    
    override init() {
        super.init()
        
        self.type = "Object"
    }
    
    override func parse(input: String, startIndex: String.Index) -> String.Index? {
        var currentIndex = input.startIndex
        
        guard let index = self.skipWhitespaces(input: input, startIndex: currentIndex) else { return nil }
        currentIndex = index
        
        if input[currentIndex] != "{" { return nil }
        
        currentIndex = input.index(after: currentIndex)
        
        while input[currentIndex] == "\"" {
            currentIndex = input.index(after: currentIndex)
            let keyStartIndex = currentIndex
            while input[currentIndex] != "\"" {
                if input[currentIndex ..< input.index(after: currentIndex)] == "\\u" {
                    currentIndex = input.index(currentIndex, offsetBy: 6)
                } else if input[currentIndex] == "\\" {
                    currentIndex = input.index(currentIndex, offsetBy: 2)
                } else {
                    currentIndex = input.index(after: currentIndex)
                }
            }
            let key = input[keyStartIndex ..< currentIndex]
            
            currentIndex = input.index(after: currentIndex)
            
            guard var index = self.skipWhitespaces(input: input, startIndex: currentIndex) else { return nil }
            currentIndex = index
            
            if input[currentIndex] != ":" { return nil }
            
            currentIndex = input.index(after: currentIndex)
            
            guard var index = self.skipWhitespaces(input: input, startIndex: currentIndex) else { return nil }
            currentIndex = index
            
            var object
            if input[currentIndex] == "{" {
                object = JSONObjectNode()
            } else if input[currentIndex] == "[" {
                object = JSONArrayNode()
            } else if input[currentIndex] == "\"" {
                object = JSONStringNode()
            } else if input[currentIndex] == "" {
                
            }
            
            guard let _ = object.parse(input: input, startIndex: currentIndex) else { return nil }
            
            if currentIndex >= input.endIndex {
                return nil
            }
        }
        
        return nil
    }
    
    func swiftify() -> String {
        var swiftOutput = ""
        swiftOutput += "class \(self.type) {\n"
        swiftOutput += self.swiftifyVariableDeclarations()
        swiftOutput += self.swiftifyInit()
        swiftOutput += self.swiftifyClassDeclarations()
        swiftOutput += "}\n"
        return swiftOutput
    }
    
    private func swiftifyVariableDeclarations() -> String {
        var swiftOutput = ""
        for key in self.children.keys {
            if let value: JSONValueNode = self.children[key] {
                swiftOutput += "var \(key.camelCased): \(value.type)\n"
            }
        }
        swiftOutput += "\n"
        return swiftOutput
    }
    
    private func swiftifyInit() -> String {
        var swiftOutput = "init(json: JSON) {\n"
        for key in self.children.keys {
            if let value: JSONValueNode = self.children[key] {
                if value is JSONObjectNode {
                    swiftOutput += "self.\(key.camelCased) = \(self.type)(json: json[\"\(key)\"])\n"
                } else if let value = value as? JSONArrayNode {
                    swiftOutput += "self.\(key.camelCased) = Array<\(value.elementType)>()\n"
                    swiftOutput += "for \(value.elementType.lowercased()) in json[\"\(key)\"].arrayValue {\n"
                    swiftOutput += "self.\(key.camelCased).append()\n"
                    swiftOutput += "}\n"
                } else {
                    swiftOutput += "self.\(key.camelCased) = json[\"\(key)\"].\(self.type.lowercased())Value\n"
                }
            }
        }
        swiftOutput += "}\n"
        return swiftOutput
    }
    
    private func swiftifyClassDeclarations() -> String {
        var swiftOutput: String = ""
        for key in self.children.keys {
            if let value = self.children[key] as? JSONObjectNode {
                swiftOutput += value.swiftify()
            }
        }
        return swiftOutput
    }
}

class JSONArrayNode: JSONValueNode { // TODO: Fix
    var elements: [JSONValueNode] = []
    var elementType: String = "Bool"
    
//    override init?(input: String) {
//        super.init(input: input)
//        
//        self.type = "Array" // TODO: Fix
//    }
}

class JSONNumberNode: JSONValueNode {
//    override init?(input: String) {
//        super.init(input: input)
//        
//        self.type = "Double"
//    }
}

class JSONStringNode: JSONValueNode {
//    override init?(input: String) {
//        super.init(input: input)
//        
//        self.type = "String"
//    }
}

class JSONBoolNode: JSONValueNode {
//    override init?(input: String) {
//        super.init(input: input)
//        
//        self.type = "Bool"
//    }
}

class JSONNullNode: JSONValueNode {
//    override init?(input: String) {
//        super.init(input: input)
//        
//        self.type = ""
//    }
}
