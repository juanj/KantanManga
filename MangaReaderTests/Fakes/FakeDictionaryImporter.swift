//
//  FakeDictionaryImporter.swift
//  Kantan-MangaTests
//
//  Created by Juan on 6/12/20.
//

@testable import Kantan_Manga

class FakeDictionaryImporter: DictionaryImporter {
    var importedDictionaries = [(URL, CompoundDictionary)]()
    func importDictionary(path: URL, to compoundDictionary: CompoundDictionary) throws {
        importedDictionaries.append((path, compoundDictionary))
    }
}
