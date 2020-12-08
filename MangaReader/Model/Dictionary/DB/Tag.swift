//
//  Tag.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Tag {
    let id: Int
    let dictionary: Int
    let category: String
    let order: Int?
    let notes: String
    let score: Int
}

extension Tag: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, dictionary, category, order, notes, score
    }

    static var databaseTableName = "tags"
}

extension Tag: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        dictionary = row[Columns.dictionary]
        category = row[Columns.category]
        order = row[Columns.order]
        notes = row[Columns.notes]
        score = row[Columns.score]
    }
}
