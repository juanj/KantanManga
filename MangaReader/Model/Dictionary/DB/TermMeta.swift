//
//  TermMeta.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct TermMeta {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    struct PitchAccent: Codable {
        let position: Int
        let tags: [String]?
    }

    enum Mode {
        case freq(frequency: Int, reading: String? = nil)
        case pitch(reading: String, pitches: [PitchAccent])
    }

    private(set) var id: Int?
    let dictionary: Int
    let character: String
    let mode: Mode

    init(from termMetaEntry: TermMetaEntry, dictionaryId: Int) {
        id = nil
        dictionary = dictionaryId
        character = termMetaEntry.character
        mode = termMetaEntry.mode
    }
}

extension TermMeta: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, dictionary, character, mode
    }

    static var databaseTableName = "termsMeta"
}

extension TermMeta: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        dictionary = row[Columns.dictionary]
        character = row[Columns.character]

        mode = (try? TermMeta.decoder.decode(TermMeta.Mode.self, from: (row[Columns.mode] as String).data(using: .utf8) ?? Data())) ?? .freq(frequency: 0, reading: nil)
    }
}

extension TermMeta: MutablePersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.dictionary] = dictionary
        container[Columns.character] = character

        // For some reason JSONEncoder delays memory release causing a huge memory usage
        // Adding an autorelease pool solves the issue
        autoreleasepool {
            container[Columns.mode] = (try? TermMeta.encoder.encode(mode)) ?? ""
        }
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }
}

extension TermMeta.Mode: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, frequency, reading, pitches
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "freq":
            let frequency = try container.decode(Int.self, forKey: .frequency)
            let reading = try? container.decode(String.self, forKey: .reading)

            self = .freq(frequency: frequency, reading: reading)
        case "pitch":
            let reading = try container.decode(String.self, forKey: .reading)
            let pitches = try container.decode([TermMeta.PitchAccent].self, forKey: .pitches)

            self = .pitch(reading: reading, pitches: pitches)
        default:
            self = .freq(frequency: 0, reading: nil)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .freq(let frequency, let reading):
            try container.encode("freq", forKey: .type)
            try container.encode(frequency, forKey: .frequency)
            try container.encodeIfPresent(reading, forKey: .reading)
        case .pitch(let reading, let pitches):
            try container.encode("pitch", forKey: .type)
            try container.encode(reading, forKey: .reading)
            try container.encode(pitches, forKey: .pitches)
        }
    }
}
