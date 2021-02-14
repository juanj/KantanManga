//
//  TermMetaSearchResult.swift
//  Kantan-Manga
//
//  Created by Juan on 18/01/21.
//

import Foundation
import GRDB

struct TermMetaSearchResult: FetchableRecord {
    init(row: Row) {
        termMeta = TermMeta(row: row)
        dictionary = row["dictionary"]
    }

    var termMeta: TermMeta
    var dictionary: Dictionary
}
