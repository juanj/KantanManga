//
//  KanjiEntryV3.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct KanjiEntryV3: KanjiEntry {
    let character: String
    let onyomi: String
    let kunyomi: String
    let tags: String
    let meanings: [String]
    let stats: [String: String]
}

extension KanjiEntryV3: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        character = try values.decode(String.self)
        onyomi = try values.decode(String.self)
        kunyomi = try values.decode(String.self)
        tags = try values.decode(String.self)
        meanings = try values.decode([String].self)
        stats = try values.decode([String: String].self)
    }
}
