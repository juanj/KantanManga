//
//  Kanji.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Kanji {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    private(set) var id: Int?
    let dictionaryId: Int
    let character: String
    let onyomi: String
    let kunyomi: String
    let tags: String
    let meanings: [String]
    let stats: [String: String]

    init(from kanjiEntry: KanjiEntry, dictionaryId: Int) {
        self.dictionaryId = dictionaryId
        character = kanjiEntry.character
        onyomi = kanjiEntry.onyomi
        kunyomi = kanjiEntry.kunyomi
        tags = kanjiEntry.tags
        meanings = kanjiEntry.meanings
        stats = kanjiEntry.stats
    }
}

extension Kanji: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, dictionaryId, character, onyomi, kunyomi, tags, meanings, stats
    }

    static var databaseTableName = "kanji"
}

extension Kanji: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        dictionaryId = row[Columns.dictionaryId]
        character = row[Columns.character]
        onyomi = row[Columns.onyomi]
        kunyomi = row[Columns.kunyomi]
        tags = row[Columns.tags]
        meanings = (try? Kanji.decoder.decode([String].self, from: (row[Columns.meanings] as String).data(using: .utf8) ?? Data())) ?? []
        stats = (try? Kanji.decoder.decode([String: String].self, from: (row[Columns.stats] as String).data(using: .utf8) ?? Data())) ?? [:]
    }
}

extension Kanji: MutablePersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.dictionaryId] = dictionaryId
        container[Columns.character] = character
        container[Columns.onyomi] = onyomi
        container[Columns.kunyomi] = kunyomi
        container[Columns.tags] = tags

        // For some reason JSONEncoder delays memory release causing a huge memory usage
        // Adding an autorelease pool solves the issue
        autoreleasepool {
            container[Columns.meanings] = (try? TermMeta.encoder.encode(meanings)) ?? ""
            container[Columns.stats] = (try? TermMeta.encoder.encode(stats)) ?? ""
        }
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }
}
