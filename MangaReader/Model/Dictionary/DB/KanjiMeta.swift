//
//  KanjiMeta.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct KanjiMeta {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    enum Category: CustomStringConvertible {
        case freq(Int)

        var description: String {
            switch self {
            case .freq(let freq):
                return "freq \(freq)"
            }
        }
    }

    private(set) var id: Int?
    let dictionaryId: Int
    let character: String
    let category: Category

    init(from kanjiMetaEntry: KanjiMetaEntry, dictionaryId: Int) {
        id = nil
        self.dictionaryId = dictionaryId
        character = kanjiMetaEntry.character
        category = kanjiMetaEntry.category
    }
}

extension KanjiMeta: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, dictionaryId, character, category
    }

    static var databaseTableName = "kanjiMeta"
    static var dictionary = belongsTo(Dictionary.self)
}

extension KanjiMeta: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        dictionaryId = row[Columns.dictionaryId]
        character = row[Columns.character]
        category = (try? KanjiMeta.decoder.decode(Category.self, from: (row[Columns.category] as String).data(using: .utf8) ?? Data())) ?? .freq(0)
    }
}

extension KanjiMeta: MutablePersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.dictionaryId] = dictionaryId
        container[Columns.character] = character

        // For some reason JSONEncoder delays memory release causing a huge memory usage
        // Adding an autorelease pool solves the issue
        autoreleasepool {
            container[Columns.category] = (try? TermMeta.encoder.encode(category)) ?? ""
        }
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }

    var dictionary: QueryInterfaceRequest<Dictionary> {
        request(for: KanjiMeta.dictionary)
    }
}

extension KanjiMeta.Category: Codable {
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

extension KanjiMeta: CustomStringConvertible {
    var description: String {
        "id: \(id ?? -1), dictionaryId: \(dictionaryId), character: \(character), category: \(category)"
    }
}
