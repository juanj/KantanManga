//
//  KanjiRadicalRelation.swift
//  Kantan-Keyboard
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct KanjiRadicalRelation {
    let kanjiId: Int
    let radicalId: Int
}

extension KanjiRadicalRelation: TableRecord {
    enum Columns: String, ColumnExpression {
        case kanjiId = "kanji_id"
        case radicalId = "radical_id"
    }

    static var databaseTableName = "radk_kanji_radical"
}

extension KanjiRadicalRelation: FetchableRecord {
    init(row: Row) {
        kanjiId = row[Columns.kanjiId]
        radicalId = row[Columns.radicalId]
    }
}
