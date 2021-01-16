//
//  DictionaryImporter.swift
//  Kantan-MangaTests
//
//  Created by Juan on 6/12/20.
//

import Foundation

protocol DictionaryDecoder {
    func decodeDictionary(path: URL, to compoundDictionary: CompoundDictionary) throws -> DecodedDictionary
}
