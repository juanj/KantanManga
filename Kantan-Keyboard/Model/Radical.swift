//
//  Radical.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import Foundation
import GRDB

struct Radical: Equatable {
    let character: String
    let strokeCount: Int
    let rowId: Int64

    func onlyRadicalPart() -> String {
        // Radkfile use a kanji to represent these radicals
        let exceptions = [
            "化": "⺅",
            "个": "𠆢",
            "并": "丷",
            "刈": "⺉",
            "乞": "𠂉",
            "込": "⻌",
            "尚": "⺌",
            "忙": "⺖",
            "扎": "⺘",
            "汁": "⺡",
            "犯": "⺨",
            "艾": "⺾",
            "邦": "⻏",
            "阡": "⻖",
            "老": "⺹",
            "杰": "⺣",
            "礼": "⺭",
            "疔": "疒",
            "禹": "禸",
            "初": "⻂",
            "買": "⺲",
            "滴": "啇"
        ]

        return exceptions[character] ?? character
    }
}

extension Radical: TableRecord {
    enum Columns: String, ColumnExpression {
        case rowId, data
        case strokeCount = "stroke_count"
    }

    static var databaseTableName: String = "radk_radicals"
    static var databaseSelection: [SQLSelectable] = [AllColumns(), Columns.rowId]
}

extension Radical: FetchableRecord {
    init(row: Row) {
        rowId = row[Columns.rowId]
        character = row[Columns.data]
        strokeCount = row[Columns.strokeCount]
    }
}
