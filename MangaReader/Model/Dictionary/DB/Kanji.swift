//
//  Kanji.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Kanji {
    let id: Int
    let dictionary: Int
    let character: String
    let onyomi: String
    let kunyomi: String
    let tags: String
    let meanings: String
    let stats: String
}

extension Kanji: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, dictionary, character, onyomi, kunyomi, tags, meanings, stats
    }

    static var databaseTableName = "kanji"
}

extension Kanji: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        dictionary = row[Columns.dictionary]
        character = row[Columns.character]
        onyomi = row[Columns.onyomi]
        kunyomi = row[Columns.kunyomi]
        tags = row[Columns.tags]
        meanings = row[Columns.meanings]
        stats = row[Columns.stats]
    }
}
