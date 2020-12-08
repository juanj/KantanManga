//
//  DecodedDictionary.swift
//  Kantan-Manga
//
//  Created by Juan on 29/11/20.
//

import Foundation

struct DecodedDictionary {
    let index: DictionaryIndex
    let termList: [TermEntry]
    let termMetaList: [TermMetaEntry]
    let kanjiList: [KanjiEntry]
    let kanjiMetaList: [KanjiMetaEntry]
    let tags: [TagEntry]
}
