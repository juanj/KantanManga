//
//  TermEntryV3.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct TermEntryV3: TermEntry, Equatable {
    let expression: String
    let reading: String
    let definitionTags: String?
    let rules: String
    let score: Int
    let glossary: [String] // TODO: implement detailed definitions
    let sequence: Int
    let termTags: String
}

extension TermEntryV3: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        expression = try values.decode(String.self)
        reading = try values.decode(String.self)
        definitionTags = try? values.decode(String.self)
        rules = try values.decode(String.self)
        score = try values.decode(Int.self)

        glossary = try values.decode([String].self)
        sequence = try values.decode(Int.self)
        termTags = try values.decode(String.self)
    }
}
