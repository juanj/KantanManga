//
//  TermMeta.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct TermMeta {
    let id: Int
    let dictionary: Int
    let character: Int
    let mode: String
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
