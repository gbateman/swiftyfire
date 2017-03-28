//
//  main.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-03.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

enum FileError: Error {
    case unableToFindFile
}

func main() {
    let tokenizer = Tokenizer()
    let parser = Parser()
    let swiftifier = Swiftifier()
    
    do {
        let input: (name: String?, text: String)
        try input = getInput()
        try tokenizer.tokenize(input.text)
        try parser.parse(tokens: tokenizer.tokens)
        try swiftifier.swiftifyJSON(parser.topLevelNode, with: input.name)
    } catch {
        print("ERROR: \(error), program will exit")
        return
    }
    
    printHeader()
    printImports()
    print(swiftifier.swiftifiedJSON)
}

func getInput() throws -> (String?, String) {
    var name: String? = nil
    var text = ""
    let arguments = CommandLine.arguments
    if arguments.count < 2 {
        while let line = readLine(strippingNewline: true) {
            text += line
        }
        let ignorableCharacters = CharacterSet.controlCharacters.union(CharacterSet.whitespacesAndNewlines)
        text = text.trimmingCharacters(in: ignorableCharacters)
    } else {
        do {
            try text = String(contentsOfFile: arguments[1], encoding: .utf8)
            text = text.replacingOccurrences(of: "\n", with: "")
            name = arguments[1]
        } catch {
            throw FileError.unableToFindFile
        }
    }
    return (name, text)
}

func printHeader() {
    print("//")
    print("// model.swift")
    print("// project")
    print("//")
    print("// Created by SwiftyFire on \(getDate())")
    print("// SwiftyFire is a development tool made by Greg Bateman")
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
