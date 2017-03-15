//
//  main.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-03.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

func main() {
    print("Enter input file:")
    var input = ""
    while let line = readLine(strippingNewline: true) {
        input += line
    }
    let ignorableCharacters = CharacterSet.controlCharacters.union(CharacterSet.whitespacesAndNewlines)
    input = input.trimmingCharacters(in: ignorableCharacters)
    
    let tokenizer = Tokenizer()
    let parser = Parser()
    let swiftifier = Swiftifier()
    do {
        try tokenizer.tokenize(input)
        try parser.parse(tokens: tokenizer.tokens)
        try swiftifier.swiftifyJSON(parser.topLevelNode)
    } catch Tokenizer.TokenizerError.illegalChar {
        print("FATAL ERROR: Control characters are not valid in JSON")
        return
    } catch {
        print("ERROR: Program will exit")
        return
    }
    
    print(swiftifier.swiftifiedJSON)
    
    print("end of output")
}

func printError() {
    print("Error in creating JSON Model")
}

func printHeader() {
    print("//")
    print("// model.swift")
    print("// project")
    print("//")
    print("// Created by SwiftyJSON Model Maker on \(getDate())")
    print("// SwiftyJSON Model Maker is a development tool made by Greg Bateman")
    print("// It was created to reduce the tedious amount of time required to create")
    print("// JSON model classes when using SwiftyJSON to parse JSON in swift")
    print("//")
    print()
}

func printImports() {
    print("import SwiftyJSON")
    print()
}

func getDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date())
}

main()
