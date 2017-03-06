//
//  StringUtils.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-04.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

extension String {
    var camelCased: String {
        let delimiters = CharacterSet(charactersIn: " _")
        var words = self.components(separatedBy: delimiters)
        
        guard let firstWord = words.first else { return "" }
        words.removeFirst()
        
        var camelCasedSelf = firstWord
        for word in words {
            camelCasedSelf += word.capitalized
        }
        return camelCasedSelf
    }
}
