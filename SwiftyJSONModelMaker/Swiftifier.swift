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
    }
    
    var swiftifiedJSON: String = ""
    
    func swiftifyJSON(_ value: JSONValueNode) throws {
        var swiftOutput = ""
        if let object = value as? JSONObjectNode {
            swiftOutput += self.swiftifyObject(object)
        } else {
            throw SwiftifierError.notAnObject
        }
        self.swiftifiedJSON = swiftOutput
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
                    if value is JSONObjectNode {
                        swiftOutput += "self.\(key.camelCased) = \(object.type)(json: json[\"\(key)\"])\n"
                    } else if let value = value as? JSONArrayNode {
                        swiftOutput += "self.\(key.camelCased) = Array<\(value.elementType)>()\n"
                        swiftOutput += "for \(value.elementType.lowercased()) in json[\"\(key)\"].arrayValue {\n"
                        swiftOutput += "self.\(key.camelCased).append()\n"
                        swiftOutput += "}\n"
                    } else {
                        swiftOutput += "self.\(key.camelCased) = json[\"\(key)\"].\(value.type.lowercased())Value\n"
                    }
                }
            }
            swiftOutput += "}\n"
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
