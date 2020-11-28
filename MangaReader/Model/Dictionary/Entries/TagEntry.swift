//
//  TagEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct TagEntry: Equatable {
    let name: String
    let category: String
    let order: Int
    let notes: String
    let score: Int
}

extension TagEntry: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        name = try values.decode(String.self)
        category = try values.decode(String.self)
        order = try values.decode(Int.self)
        notes = try values.decode(String.self)
        score = try values.decode(Int.self)
    }
}
