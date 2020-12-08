//
//  KanjiMeta.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct KanjiMeta {
    let id: Int
    let dictionary: Int
    let character: String
    let category: String
}

extension KanjiMeta: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, dictionary, character, category
    }

    static var databaseTableName = "kanjiMeta"
}

extension KanjiMeta: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        dictionary = row[Columns.dictionary]
        character = row[Columns.character]
        category = row[Columns.category]
    }
}
