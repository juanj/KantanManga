//
//  KanjiEntryV1.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct KanjiEntryV1: KanjiEntry {
    let character: String
    let onyomi: String
    let kunyomi: String
    let tags: String
    let meanings: [String]
    let stats = [String: String]()
}

extension KanjiEntryV1: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        character = try values.decode(String.self)
        onyomi = try values.decode(String.self)
        kunyomi = try values.decode(String.self)
        tags = try values.decode(String.self)

        var meanings = [String]()
        while !values.isAtEnd {
            meanings.append(try values.decode(String.self))
        }
        self.meanings = meanings
    }
}
