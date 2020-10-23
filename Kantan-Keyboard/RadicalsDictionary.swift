//
//  RadicalsDictionary.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import Foundation
import SQLite

class RadicalsDictionary {
    private let radkDb: Connection
    private let kanjidicDb: Connection

    init?() {
        guard let radkDbUrl = Bundle.main.url(forResource: "radk.sqlite", withExtension: "db"),
              let kanjidicDbUrl = Bundle.main.url(forResource: "kanjidic.sqlite", withExtension: "db") else {
            return nil
        }
        do {
            radkDb = try Connection(radkDbUrl.absoluteString, readonly: true)
            kanjidicDb = try Connection(kanjidicDbUrl.absoluteString, readonly: true)
        } catch {
            return nil
        }
    }

    func getRadicals() -> [Radical] {
        let radicalsTable = Table("radk_radicals")
        let radicalColumn = Expression<String>("data")
        let strokeCountColumn = Expression<Int>("stroke_count")

        do {
            let entries = Array(try radkDb.prepare(radicalsTable.select(rowid, radicalColumn, strokeCountColumn).order(strokeCountColumn.asc)))
            return entries.map { Radical(character: $0[radicalColumn], strokeCount: $0[strokeCountColumn], rowId: $0[rowid]) }
        } catch {
            return []
        }
    }

    func getKanjiWith(radicals: [Radical]) -> [Kanji] {
        var radicals = radicals
        let radkKanjiRadicalTable = Table("radk_kanji_radical")
        let radkKanjiIdColumn = Expression<Int64>("kanji_id")
        let radkRadicalIdColumn = Expression<Int64>("radical_id")

        let radkKanjiTable = Table("radk_kanji")
        let radkDataColumn = Expression<String>("data")

        let kanjidicKanjiTable = Table("kanjidict_kanji")
        let kanjidicLiteralColumn = Expression<String>("literal")
        let kanjidicStrokeCountColumn = Expression<Int>("stroke_count")

        guard let firstRadical = radicals.popLast() else {
            return []
        }

        do {
            var kanjiIds = Array(try radkDb.prepare(radkKanjiRadicalTable.filter(radkRadicalIdColumn == firstRadical.rowId)))
                .map { $0[radkKanjiIdColumn] }

            for radical in radicals {
                kanjiIds = Array(try radkDb.prepare(radkKanjiRadicalTable.filter(kanjiIds.contains(radkKanjiIdColumn) && radkRadicalIdColumn == radical.rowId)))
                    .map { $0[radkKanjiIdColumn] }
            }

            let kanjiRows = Array(try radkDb.prepare(radkKanjiTable.select(rowid, radkDataColumn).filter(kanjiIds.contains(rowid)).order(radkDataColumn.desc)))
            let kanjiCharacters = kanjiRows.map { $0[radkDataColumn] }
            let kanjiInfo = Array(try kanjidicDb.prepare(kanjidicKanjiTable.select(kanjidicLiteralColumn, kanjidicStrokeCountColumn).filter(kanjiCharacters.contains(kanjidicLiteralColumn)).order(kanjidicLiteralColumn.desc)))

            // TODO: This is tremendously slow
            let kanjis = kanjiRows.map { row -> Kanji in
                if let info = kanjiInfo.first(where: { $0[kanjidicLiteralColumn] == row[radkDataColumn] }) {
                    return Kanji(character: row[radkDataColumn], strokeCount: info[kanjidicStrokeCountColumn], rowId: row[rowid])
                }
                return Kanji(character: row[radkDataColumn], strokeCount: 100, rowId: row[rowid])
            }

            return kanjis.sorted(by: { $0.strokeCount < $1.strokeCount })
        } catch {
            return []
        }
    }

    func getValidRadicalsWith(selection: [Radical]) -> [Radical] {
        guard selection.count > 0 else {
            return getRadicals()
        }

        let kanjiIds = getKanjiWith(radicals: selection).map(\.rowId)
        let kanjiRadicalTable = Table("radk_kanji_radical")
        let kanjiIdColumn = Expression<Int64>("kanji_id")
        let radicalIdColumn = Expression<Int64>("radical_id")

        let radicalsTable = Table("radk_radicals")
        let radicalColumn = Expression<String>("data")
        let strokeCountColumn = Expression<Int>("stroke_count")

        do {
            let radicalIds = Array(try radkDb.prepare(kanjiRadicalTable.filter(kanjiIds.contains(kanjiIdColumn)))).map { $0[radicalIdColumn] }
            return Array(try radkDb.prepare(radicalsTable.select(rowid, radicalColumn, strokeCountColumn).filter(radicalIds.contains(rowid))))
                .map { Radical(character: $0[radicalColumn], strokeCount: $0[strokeCountColumn], rowId: $0[rowid]) }
        } catch {
            return []
        }
    }
}
