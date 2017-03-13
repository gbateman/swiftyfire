//
//  JSONNodes.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-03.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

class JSONValueNode {
    var type: String = ""
}

class JSONObjectNode: JSONValueNode {
    var children: [String: JSONValueNode] = [:]
    
    override init() {
        super.init()
        
        self.type = "Object"
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
    
    override init() {
        super.init()
        
        self.type = "Array" // TODO: Fix
    }
}

class JSONNumberNode: JSONValueNode {
    override init() {
        super.init()
        
        self.type = "Double"
    }
}

class JSONStringNode: JSONValueNode {
    override init() {
        super.init()
        
        self.type = "String"
    }
}

class JSONBoolNode: JSONValueNode {
    override init() {
        super.init()
        
        self.type = "Bool"
    }
}

class JSONNullNode: JSONValueNode {
    override init() {
        super.init()
        
        self.type = ""
    }
}
