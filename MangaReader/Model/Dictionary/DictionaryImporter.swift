//
//  DictionaryImporter.swift
//  Kantan-MangaTests
//
//  Created by Juan on 6/12/20.
//

import Foundation

protocol DictionaryImporter {
    func importDictionary(path: URL, to compoundDictionary: CompoundDictionary) throws
}
