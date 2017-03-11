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
    var topLevelNode: JSONValueNode = JSONValueNode()
    
    func parse(tokens: [Token]) {
        for i in 0 ..< tokens.count {
            let token = tokens[i]
            if token.kind == .lbrace {
                
            }
        }
    }
}
