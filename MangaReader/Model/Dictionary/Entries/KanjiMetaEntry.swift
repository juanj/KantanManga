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

extension KanjiMetaEntry.Category: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, frequency
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        switch type {
        case "freq":
            let frequency = try values.decode(Int.self, forKey: .frequency)
            self = .freq(frequency)
        default:
            self = .freq(0)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .freq(let frquency):
            try container.encode("freq", forKey: .type)
            try container.encode(frquency, forKey: .frequency)
        }
    }
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
