//
//  Kanji.swift
//  Kantan-Keyboard
//
//  Created by Juan on 21/10/20.
//

import Foundation
import GRDB

struct Kanji: Equatable {
    let character: String
    var strokeCount: Int
    let rowId: Int64

    func withStrokeCount(_ count: Int) -> Kanji {
        Kanji(character: character, strokeCount: count, rowId: rowId)
    }
}

extension Kanji: TableRecord {
    enum Columns: String, ColumnExpression {
        case data, rowId
    }

    static var databaseTableName = "radk_kanji"
    static var databaseSelection: [SQLSelectable] = [AllColumns(), Columns.rowId]
}

extension Kanji: FetchableRecord {
    init(row: Row) {
        character = row[Columns.data]
        rowId = row[Columns.rowId]
        strokeCount = 0
    }
}
