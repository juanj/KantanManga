//
//  RadicalsDictionary.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import Foundation
import GRDB

class RadicalsDictionary {
    private let radkDbQueue: DatabaseQueue
    private let kanjidicDbQueue: DatabaseQueue

    init?() {
        guard let radkDbUrl = Bundle.main.url(forResource: "radk.sqlite", withExtension: "db"),
              let kanjidicDbUrl = Bundle.main.url(forResource: "kanjidic.sqlite", withExtension: "db") else {
            return nil
        }
        do {
            var radkConfiguration = Configuration()
            radkConfiguration.readonly = true
            radkConfiguration.label = "RadkDB"
            radkDbQueue = try DatabaseQueue(path: radkDbUrl.absoluteString, configuration: radkConfiguration)

            var kanjidicConfiguration = Configuration()
            kanjidicConfiguration.readonly = true
            kanjidicConfiguration.label = "KanjidicDB"
            kanjidicDbQueue = try DatabaseQueue(path: kanjidicDbUrl.absoluteString, configuration: kanjidicConfiguration)
        } catch {
            return nil
        }
    }

    func getRadicals() -> [Radical] {
        do {
            let radicals = try radkDbQueue.read { db in
                try Radical
                    .order(Radical.Columns.strokeCount.asc)
                    .fetchAll(db)
            }
            return radicals
        } catch {
            return []
        }
    }

    func getKanjiWith(radicals: [Radical]) -> [Kanji] {
        var radicals = radicals
        guard let firstRadical = radicals.popLast() else {
            return []
        }

        do {
            var kanjiIds = try radkDbQueue.read { db in
                try KanjiRadicalRelation
                    .filter(KanjiRadicalRelation.Columns.radicalId == firstRadical.rowId)
                    .fetchAll(db)
                    .map(\.kanjiId)
            }

            for radical in radicals {
                kanjiIds = try radkDbQueue.read { db in
                    try KanjiRadicalRelation
                        .filter(kanjiIds.contains(KanjiRadicalRelation.Columns.kanjiId) && KanjiRadicalRelation.Columns.radicalId == radical.rowId)
                        .fetchAll(db)
                        .map(\.kanjiId)
                }
            }

            let kanjiRows = try radkDbQueue.read { db in
                try Kanji
                    .filter(kanjiIds.contains(Kanji.Columns.rowId))
                    .order(Kanji.Columns.data.desc)
                    .fetchAll(db)
            }

            let kanjiCharacters = kanjiRows.map(\.character)

            // TODO: Merge radk and kanjidic to query only one table
            let kanjiInfo = try kanjidicDbQueue.read { db in
                try DicKanji
                    .filter(kanjiCharacters.contains(DicKanji.Columns.character))
                    .order(DicKanji.Columns.character.desc)
                    .fetchAll(db)
            }

            // It's safe to assume all kanjis contained in radkfile are in kanjidic
            let kanjis = zip(kanjiRows, kanjiInfo)
                .map { $0.0.withStrokeCount($0.1.strokeCount)}
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
        do {
            let radicalIds = try radkDbQueue.read { db in
                try KanjiRadicalRelation
                    .filter(kanjiIds.contains(KanjiRadicalRelation.Columns.kanjiId))
                    .fetchAll(db)
                    .map(\.radicalId)
            }

            return try radkDbQueue.read { db in
                try Radical
                    .filter(radicalIds.contains(Radical.Columns.rowId))
                    .fetchAll(db)
            }
        } catch {
            return []
        }
    }
}
