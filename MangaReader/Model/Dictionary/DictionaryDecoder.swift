//
//  DictionaryDecoder.swift
//  Kantan-MangaTests
//
//  Created by Juan on 6/12/20.
//

import Foundation

protocol DictionaryDecoder {
    func decodeDictionary(path: URL, progress: ((Float) -> Void)?) throws -> DecodedDictionary
}

extension DictionaryDecoder {
    func decodeDictionary(path: URL, progress: ((Float) -> Void)? = nil) throws -> DecodedDictionary {
        try decodeDictionary(path: path, progress: progress)
    }
}
