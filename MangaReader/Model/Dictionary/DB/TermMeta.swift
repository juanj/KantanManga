//
//  TermMeta.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct TermMeta {
    let id: Int // = Expression<Int64>("id")
    let dictionary: Int // = Expression<Int64>("dictionary")
    let character: Int // = Expression<String>("character")
    let mode: String // = Expression<String>("mode")
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
        mode = row[Columns.mode]
    }
}
