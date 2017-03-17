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
    }
    
    var swiftifiedJSON: String = ""
    
    func swiftifyJSON(_ value: JSONValueNode) throws {
        var swiftOutput = ""
        if let object = value as? JSONObjectNode {
            object.name = "TopLevelObject" // TODO: Replace with file name
            self.giveNamesToNodes(in: object)
            swiftOutput += self.swiftifyObject(object)
        } else {
            throw SwiftifierError.notAnObject
        }
        self.swiftifiedJSON = swiftOutput
    }
    
    private func giveNamesToNodes(in node: JSONObjectNode) {
        for key in node.children.keys {
            if let object = node.children[key] as? JSONObjectNode {
                object.name = key.capitalCased
                self.giveNamesToNodes(in: object)
            } else if let array = node.children[key] as? JSONArrayNode {
                array.elementType = key.capitalCased + "Element"
                self.giveNamesToNodes(in: array)
            }
        }
    }
    
    private func giveNamesToNodes(in node: JSONArrayNode) {
        for element in node.elements {
            if let object = element as? JSONObjectNode {
                object.name = node.elementType.capitalCased
                self.giveNamesToNodes(in: object)
            } else if let array = element as? JSONArrayNode {
                array.elementType = node.elementType + "Element"
                self.giveNamesToNodes(in: array)
            }
        }
    }
    
    private func swiftifyObject(_ object: JSONObjectNode) -> String {
        func swiftifyVariableDeclarations() -> String {
            var swiftOutput = ""
            for key in object.children.keys {
                if let value: JSONValueNode = object.children[key] {
                    swiftOutput += "var \(key.camelCased): \(value.type)\n"
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
            swiftOutput += "self.\(key.camelCased) = \(swiftifyAssignment(for: key, and: value))"
            return swiftOutput
        }
        
        func swiftifyAssignment(for key: String, and value: JSONValueNode) -> String {
            var swiftOutput = ""
            if let object = value as? JSONObjectNode {
                swiftOutput += "\(object.type)(json: json[\"\(key)\"])\n"
            } else if let array = value as? JSONArrayNode {
                swiftOutput += "json[\"\(key)\"].\(value.type.lowercased())Value.map({ element in\n"
                swiftOutput += "return \(swiftifyAssignment(for: "asdfasdfasdfasdferror", and: JSONValueNode()))"
                swiftOutput += "})\n"
            } else {
                swiftOutput += "json[\"\(key)\"].\(value.type.lowercased())Value\n"
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
        swiftOutput += "class \(object.type) {\n"
        swiftOutput += swiftifyVariableDeclarations()
        swiftOutput += swiftifyInit()
        swiftOutput += swiftifyClassDeclarations()
        swiftOutput += "}\n"
        return swiftOutput
    }
}
