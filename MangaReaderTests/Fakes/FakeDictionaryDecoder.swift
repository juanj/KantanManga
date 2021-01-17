//
//  FakeDictionaryDecoder.swift
//  Kantan-MangaTests
//
//  Created by Juan on 6/12/20.
//

@testable import Kantan_Manga

class FakeDictionaryDecoder: DictionaryDecoder {
    weak var delegate: DictionaryDecoderDelegate?
    var decodedDictionaries = [URL]()
    func decodeDictionary(path: URL, indexCallback: ((DictionaryIndex) -> Void)?, progress: ((Float) -> Void)?) throws -> DecodedDictionary {
        decodedDictionaries.append(path)
        return DecodedDictionary(index: DictionaryIndex(title: "", revision: "", sequenced: nil, format: nil, version: nil, author: nil, url: nil, description: nil, attribution: nil), termList: [], termMetaList: [], kanjiList: [], kanjiMetaList: [], tags: [])
    }
}
