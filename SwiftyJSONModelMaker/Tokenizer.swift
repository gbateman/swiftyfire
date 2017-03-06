//
//  Tokenizer.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-05.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

class Tokenizer {
    enum Kind {
        case lbrace
        case rbrace
        case lbrack
        case rbrack
        case colon
        case comma
        case whiteSpace
        case stringLiteral
        case trueLiteral
        case falseLiteral
        case nullLiteral
        case numberLiteral
    }
}
