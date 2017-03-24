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
    var name: String = "Greg"
    
    override init() {
        super.init()
        
        self.type = "Object"
    }
}

class JSONArrayNode: JSONValueNode { // TODO: Fix
    var elements: [JSONValueNode] = []
    var name: String = "GregA"
    var elementType: String = ""
    
    override init() {
        super.init()
        
        self.type = "Array"
    }
}

class JSONNumberNode: JSONValueNode {
    var value: Double = 0
    
    override init() {
        super.init()
        
        self.type = "Double"
    }
}

class JSONStringNode: JSONValueNode {
    var value: String = ""
    override init() {
        super.init()
        
        self.type = "String"
    }
}

class JSONBoolNode: JSONValueNode {
    var value: Bool = false
    
    override init() {
        super.init()
        
        self.type = "Bool"
    }
}

class JSONNullNode: JSONValueNode {
    override init() {
        super.init()
        
        self.type = "null"
    }
}
