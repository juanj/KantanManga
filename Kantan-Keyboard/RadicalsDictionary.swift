//
//  RadicalsDictionary.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import Foundation
import SQLite

class RadicalsDictionary {
    private let connection: Connection

    init?() {
        guard let dbUrl = Bundle.main.url(forResource: "radk.sqlite", withExtension: "db") else {
            return nil
        }
        do {
            connection = try Connection(dbUrl.absoluteString, readonly: true)
        } catch {
            return nil
        }
    }

    func getRadials() -> [Radical] {
        let radicalsTable = Table("radk_radicals")
        let radicalColumn = Expression<String>("data")
        let strokeCountColumn = Expression<Int>("stroke_count")

        do {
            let entries = Array(try connection.prepare(radicalsTable.select(rowid, radicalColumn, strokeCountColumn).order(strokeCountColumn.asc)))
            return entries.map { Radical(character: $0[radicalColumn], strokeCount: $0[strokeCountColumn], rowId: $0[rowid]) }
        } catch {
            return []
        }
    }

    func getKanjiWith(radicals: [Radical]) -> [String] {
        var radicals = radicals
        let kanjiRadicalTable = Table("radk_kanji_radical")
        let kanjiIdColumn = Expression<Int64>("kanji_id")
        let radicalIdColumn = Expression<Int64>("radical_id")

        let kanjiTable = Table("radk_kanji")
        let dataColumn = Expression<String>("data")

        guard let firstRadical = radicals.popLast() else {
            return []
        }

        do {
            var kanjiIds = Array(try connection.prepare(kanjiRadicalTable.filter(radicalIdColumn == firstRadical.rowId)))
                .map { $0[kanjiIdColumn] }

            for radical in radicals {
                kanjiIds = Array(try connection.prepare(kanjiRadicalTable.filter(kanjiIds.contains(kanjiIdColumn) && radicalIdColumn == radical.rowId)))
                    .map { $0[kanjiIdColumn] }
            }

            return Array(try connection.prepare(kanjiTable.filter(kanjiIds.contains(rowid))))
                .map { $0[dataColumn] }

        } catch {
            return []
        }
    }
}
