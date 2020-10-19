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
            let entries = Array(try connection.prepare(radicalsTable.order(strokeCountColumn.asc)))
            return entries.map { Radical(character: $0[radicalColumn], strokeCount: $0[strokeCountColumn]) }
        } catch {
            return []
        }
    }
}
