//
//  Swiftifier.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-14.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

class Swiftifier {
    enum SwiftifierError: Error {
        case notAnObject
        case emptyArray
        case nullArray
    }
    
    var swiftifiedJSON: String = ""
    
    func swiftifyJSON(_ value: JSONValueNode, with name: String?) throws {
        var swiftOutput = ""
        if let object = value as? JSONObjectNode {
            object.name = name ?? "Object"
            self.giveNamesToNodes(in: object)
            try self.giveElementTypesToArrays(in: object)
            swiftOutput += self.swiftifyObject(object)
        } else {
            throw SwiftifierError.notAnObject
        }
        self.swiftifiedJSON = swiftOutput
    }
    
    // TODO: fix naming
    private func giveNamesToNodes(in node: JSONObjectNode) {
        for key in node.children.keys {
            guard let value = node.children[key] else { return }
            
            if let object = value as? JSONObjectNode {
                object.name = key.capitalCased
                self.giveNamesToNodes(in: object)
            } else if let array = value as? JSONArrayNode {
                array.name = key.capitalCased
                self.giveNamesToNodes(in: array)
            }
        }
    }
    
    private func giveNamesToNodes(in node: JSONArrayNode) {
        let elementName = node.name + "Element"
        for element in node.elements {
            if let object = element as? JSONObjectNode {
                object.name = elementName
                self.giveNamesToNodes(in: object)
            } else if let array = element as? JSONArrayNode {
                array.name = elementName
                self.giveNamesToNodes(in: array)
            }
        }
    }
    
    private func giveElementTypesToArrays(in node: JSONObjectNode) throws {
        for key in node.children.keys {
            guard let value = node.children[key] else { return }
            
            if let array = value as? JSONArrayNode {
                try self.giveElementTypesToArrays(in: array)
                try self.giveElementType(to: array)
            }
        }
    }
    
    private func giveElementTypesToArrays(in node: JSONArrayNode) throws {
        for element in node.elements {
            if let array = element as? JSONArrayNode {
                try self.giveElementTypesToArrays(in: array)
                try self.giveElementType(to: array)
            }
        }
    }
    
    private func giveElementType(to array: JSONArrayNode) throws {
        guard let first = array.elements.first else { throw SwiftifierError.emptyArray }
        
        if let _ = first as? JSONNullNode {
            throw SwiftifierError.nullArray
        } else if let subarray = first as? JSONArrayNode {
            array.elementType = "[\(subarray.elementType)]"
        } else if let object = first as? JSONObjectNode {
            array.elementType = object.name
        } else {
            array.elementType = first.type
        }
    }
    
    private func swiftifyObject(_ object: JSONObjectNode) -> String {
        func swiftifyVariableDeclarations() -> String {
            var swiftOutput = ""
            for key in object.children.keys {
                if let value: JSONValueNode = object.children[key] {
                    if let array = value as? JSONArrayNode {
                        swiftOutput += "var \(key.camelCased): [\(array.elementType)]\n"
                    } else {
                        swiftOutput += "var \(key.camelCased): \(value.type)\n"
                    }
                }
            }
            swiftOutput += "\n"
            return swiftOutput
        }
        
        func swiftifyInit() -> String {
            var swiftOutput = "init(json: JSON) {\n"
            for key in object.children.keys {
                if let value: JSONValueNode = object.children[key] {
                    swiftOutput += swiftifyValueInstantiation(for: key, and: value)
                }
            }
            swiftOutput += "}\n"
            return swiftOutput
        }
        
        func swiftifyValueInstantiation(for key: String, and value: JSONValueNode) -> String {
            var swiftOutput = ""
            swiftOutput += "self.\(key.camelCased) = \(swiftifyAssignment(for: "json[\"\(key)\"]", and: value))"
            return swiftOutput
        }
        
        func swiftifyAssignment(for key: String, and value: JSONValueNode) -> String {
            var swiftOutput = ""
            if let object = value as? JSONObjectNode {
                swiftOutput += "\(object.type)(json: \(key))\n"
            } else if let array = value as? JSONArrayNode {
                swiftOutput += "\(key).arrayValue.map({ element in\n"
                if let first = array.elements.first {
                    swiftOutput += "return \(swiftifyAssignment(for: "element", and: first))"
                } else {
                    swiftOutput += "return 0\n"
                }
                swiftOutput += "})\n"
            } else {
                swiftOutput += "\(key).\(value.type.lowercased())Value\n"
            }
            return swiftOutput
        }
        
        func swiftifyClassDeclarations() -> String {
            var swiftOutput: String = ""
            for key in object.children.keys {
                if let value = object.children[key] as? JSONObjectNode {
                    swiftOutput += swiftifyObject(value)
                }
            }
            return swiftOutput
        }
        
        var swiftOutput = ""
        swiftOutput += "class \(object.name) {\n"
        swiftOutput += swiftifyVariableDeclarations()
        swiftOutput += swiftifyInit()
        swiftOutput += swiftifyClassDeclarations()
        swiftOutput += "}\n"
        return swiftOutput
    }
}
