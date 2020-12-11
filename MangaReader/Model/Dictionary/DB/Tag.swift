//
//  Tag.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Tag {
    private(set) var id: Int?
    let dictionary: Int
    let category: String
    let order: Int
    let notes: String
    let score: Int

    init(from tagEntry: TagEntry, dictionaryId: Int) {
        id = nil
        dictionary = dictionaryId
        category = tagEntry.category
        order = tagEntry.order
        notes = tagEntry.notes
        score = tagEntry.score
    }
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

extension Tag: MutablePersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.dictionary] = dictionary
        container[Columns.category] = category
        container[Columns.order] = order
        container[Columns.notes] = notes
        container[Columns.score] = score
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }
}
