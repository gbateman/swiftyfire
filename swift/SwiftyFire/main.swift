//
//  main.swift
//  SwiftyJSONModelMaker
//
//  Created by Gregory Bateman on 2017-03-03.
//  Copyright © 2017 Gregory Bateman. All rights reserved.
//

import Foundation

func main() {
    var name: String?
    let tokenizer = Tokenizer()
    let parser = Parser()
    let swiftifier = Swiftifier()

    do {
        let input: (name: String?, text: String)
        try input = getInput()
        name = input.name
        let text = input.text

        try tokenizer.tokenize(text)
        try parser.parse(tokens: tokenizer.tokens)
        try swiftifier.swiftifyJSON(parser.topLevelNode, with: name)
    } catch {
        print("ERROR: \(error), program will exit\n")
        return
    }

    printHeader(with: name)
    printImports()
    print(swiftifier.swiftifiedJSON)
}

func getInput() throws -> (String?, String) {
    var name: String? = nil
    var text = ""
    let arguments = CommandLine.arguments
    if arguments.count < 2 { // Input from standard input
        while let line = readLine(strippingNewline: true) {
            text += line
        }
        let ignorableCharacters = CharacterSet.controlCharacters.union(CharacterSet.whitespacesAndNewlines)
        text = text.trimmingCharacters(in: ignorableCharacters)
    } else { // Input from file
        do {
            try text = String(contentsOfFile: arguments[1], encoding: .utf8)
            text = text.components(separatedBy: "\r").joined(separator: "")
            text = text.components(separatedBy: "\n").joined(separator: "")
            text = text.components(separatedBy: "\t").joined(separator: "  ")
            name = arguments[1]
            while let range = name?.range(of: "/") {
                name = name?.substring(from: range.upperBound)
            }
            if let range = name?.range(of: ".") {
                name = name?.substring(to: range.lowerBound)
            }
            name = name?.capitalCased
        } catch {
            throw error
        }
    }
    return (name, text)
}

func printHeader(with name: String?) {
    print("//")
    print("// \(name ?? "Object").swift")
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
