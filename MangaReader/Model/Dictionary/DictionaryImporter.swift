//
//  DictionaryImporter.swift
//  Kantan-Manga
//
//  Created by Juan on 27/11/20.
//

import Foundation
import SQLite
import ZIPFoundation

struct DictionaryImporter {
    static let termBankFileFormat = "term_bank_%d.json"
    static let termMetaBankFileFormat = "term_meta_bank_%d.json"
    static let kanjiBankFileFormat = "kanji_bank_%d.json"
    static let kanjiMetaBankFileFormat = "kanji_meta_bank_%d.json"
    static let tagBankFileFormat = "tag_bank_%d.json"

    func importDictionary(path: URL, to compoundDictionary: CompoundDictionary) throws {
        guard let zipFile = Archive(url: path, accessMode: .read) else {
            throw DictionaryImporterError.canNotReadFile
        }

        let index = try importIndex(zip: zipFile)

        guard try compoundDictionary.dictionaryExists(title: index.title, revision: index.revision) else {
            throw DictionaryImporterError.dictionaryAlreadyExists
        }

        let termList: [TermEntry]
        let kanjiList: [KanjiEntry]
        if index.fileVersion == .v1 {
            termList = try readFileSequence(fileFormat: DictionaryImporter.termBankFileFormat, zip: zipFile) as [TermEntryV1]
            kanjiList = try readFileSequence(fileFormat: DictionaryImporter.kanjiBankFileFormat, zip: zipFile) as [KanjiEntryV1]
        } else {
            termList = try readFileSequence(fileFormat: DictionaryImporter.termBankFileFormat, zip: zipFile) as [TermEntryV3]
            kanjiList = try readFileSequence(fileFormat: DictionaryImporter.kanjiBankFileFormat, zip: zipFile) as [KanjiEntryV3]
        }
        let termMetaList: [TermMetaEntry] = try readFileSequence(fileFormat: DictionaryImporter.termMetaBankFileFormat, zip: zipFile)
        let kanjiMetaList: [KanjiMetaEntry] = try readFileSequence(fileFormat: DictionaryImporter.kanjiMetaBankFileFormat, zip: zipFile)
        let tagList: [TagEntry] = try readFileSequence(fileFormat: DictionaryImporter.tagBankFileFormat, zip: zipFile)
        // TODO: Read 'old' tags

        let dictionary = Dictionary(index: index, termList: termList, termMetaList: termMetaList, kanjiList: kanjiList, kanjiMetaList: kanjiMetaList, tags: tagList)
        try compoundDictionary.addDictionary(dictionary)
    }

    private func importIndex(zip: Archive) throws -> DictionaryIndex {
        guard let indexFile = zip["index.json"] else {
            throw DictionaryImporterError.indexNotFound
        }

        var data = Data()
        _ = try zip.extract(indexFile) { partData in
            data.append(partData)
        }

        let decoder = JSONDecoder()
        let index = try decoder.decode(DictionaryIndex.self, from: data)
        return index
    }

    private func readFileSequence<T: Decodable>(fileFormat: String, zip: Archive) throws -> [T] {
        var results = [T]()
        let decoder = JSONDecoder()
        var index = 1
        while let file = zip[String(format: fileFormat, index)] {
            var data = Data()
            _ = try zip.extract(file) { partData in
                data.append(partData)
            }
            let entries = try decoder.decode([T].self, from: data)
            results.append(contentsOf: entries)
            index += 1
        }
        return results
    }
}
