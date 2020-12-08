//
//  DicKanji.swift
//  Kantan-Keyboard
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct DicKanji {
    let character: String
    let strokeCount: Int
}

extension DicKanji: TableRecord {
    enum Columns: String, ColumnExpression {
        case character = "literal"
        case strokeCount = "stroke_count"
    }

    static var databaseTableName = "kanjidict_kanji"
}

extension DicKanji: FetchableRecord {
    init(row: Row) {
        character = row[Columns.character]
        strokeCount = row[Columns.strokeCount]
    }
}
