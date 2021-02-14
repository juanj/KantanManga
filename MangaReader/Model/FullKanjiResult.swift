//
//  FullKanjiResult.swift
//  Kantan-Manga
//
//  Created by Juan on 14/02/21.
//

import Foundation

struct FullKanjiResult {
    var kanji: Kanji
    var dictionary: Dictionary
    var meta: KanjiMetaSearchResult?

    init(kanjiResult: KanjiSearchResult, metaResult: KanjiMetaSearchResult?) {
        kanji = kanjiResult.kanji
        dictionary = kanjiResult.dictionary
        meta = metaResult
    }
}
