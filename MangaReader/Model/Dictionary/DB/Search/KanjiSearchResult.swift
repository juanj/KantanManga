//
//  KanjiSearchResult.swift
//  Kantan-Manga
//
//  Created by Juan on 14/02/21.
//

import Foundation
import GRDB

struct KanjiSearchResult: FetchableRecord {
    init(row: Row) {
        kanji = Kanji(row: row)
        dictionary = row["dictionary"]
    }

    var kanji: Kanji
    var dictionary: Dictionary
}
