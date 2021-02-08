//
//  DictionaryDecoder.swift
//  Kantan-MangaTests
//
//  Created by Juan on 6/12/20.
//

import Foundation

protocol DictionaryDecoderDelegate: AnyObject {
    func shouldContinueDecoding(dictionary: DictionaryIndex) -> Bool
}

protocol DictionaryDecoder {
    var delegate: DictionaryDecoderDelegate? { get set }
    func decodeDictionary(path: URL, indexCompletion: ((DictionaryIndex) -> Void)?, progress: ((Float) -> Void)?) throws -> DecodedDictionary
}

extension DictionaryDecoder {
    func decodeDictionary(path: URL, indexCompletion: ((DictionaryIndex) -> Void)? = nil, progress: ((Float) -> Void)? = nil) throws -> DecodedDictionary {
        try decodeDictionary(path: path, indexCompletion: indexCompletion, progress: progress)
    }
}
