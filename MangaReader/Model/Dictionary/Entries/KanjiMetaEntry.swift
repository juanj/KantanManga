//
//  KanjiMetaEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct KanjiMetaEntry {
    enum Category {
        case freq(Int)
    }

    let character: String
    let category: Category
}

extension KanjiMetaEntry: CustomStringConvertible {
    var description: String {
        return "\(character), \(category)"
    }
}

extension KanjiMetaEntry: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        character = try values.decode(String.self)
        let type = try values.decode(String.self)

        switch type {
        case "freq":
            do {
                let frequency: Int
                if let freq = try? values.decode(Int.self) {
                    frequency = freq
                } else {
                    let freq = try values.decode(String.self)
                    frequency = Int(freq) ?? 0
                }
                category = .freq(frequency)
            }
        default:
            category = .freq(0)
        }
    }
}
