//
//  KanjiMetaSearchResult.swift
//  Kantan-Manga
//
//  Created by Juan on 14/02/21.
//

import Foundation
import GRDB

struct KanjiMetaSearchResult: FetchableRecord {
    init(row: Row) {
        kanjiMeta = KanjiMeta(row: row)
        dictionary = row["dictionary"]
    }

    var kanjiMeta: KanjiMeta
    var dictionary: Dictionary
}
