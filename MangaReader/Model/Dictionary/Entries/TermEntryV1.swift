//
//  TermEntryV1.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct TermEntryV1: TermEntry, Equatable {
    let expression: String
    let reading: String
    let definitionTags: String?
    let rules: String
    let score: Int
    let glossary: [String]
    let sequence = 0
    let termTags = ""
}

extension TermEntryV1: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        expression = try values.decode(String.self)
        reading = try values.decode(String.self)
        definitionTags = try? values.decode(String.self)
        rules = try values.decode(String.self)
        score = try values.decode(Int.self)

        var glossary = [String]()
        while !values.isAtEnd {
            glossary.append(try values.decode(String.self))
        }
        self.glossary = glossary
    }
}
