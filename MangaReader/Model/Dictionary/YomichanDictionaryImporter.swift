//
//  YomichanDictionaryImporter.swift
//  Kantan-Manga
//
//  Created by Juan on 27/11/20.
//

import Foundation
import GRDB
import ZIPFoundation

class YomichanDictionaryDecoder: DictionaryDecoder {
    static let termBankFileFormat = "term_bank_%d.json"
    static let termMetaBankFileFormat = "term_meta_bank_%d.json"
    static let kanjiBankFileFormat = "kanji_bank_%d.json"
    static let kanjiMetaBankFileFormat = "kanji_meta_bank_%d.json"
    static let tagBankFileFormat = "tag_bank_%d.json"

    private var currentProgress: Float = 0
    private var numberOfFiles: Float = 1
    private var progress: ((Float) -> Void)?
    func decodeDictionary(path: URL, progress: ((Float) -> Void)?) throws -> DecodedDictionary {
        guard let zipFile = Archive(url: path, accessMode: .read) else {
            throw DictionaryDecoderError.canNotReadFile
        }

        self.currentProgress = 0
        self.progress = progress
        numberOfFiles = Float(zipFile.makeIterator().reduce(0, { $0 + ($1.type == .file ? 1 : 0) }))
        let index = try importIndex(zip: zipFile)

        let termList: [TermEntry]
        let kanjiList: [KanjiEntry]
        if index.fileVersion == .v1 {
            termList = try readFileSequence(fileFormat: YomichanDictionaryDecoder.termBankFileFormat, zip: zipFile) as [TermEntryV1]
            kanjiList = try readFileSequence(fileFormat: YomichanDictionaryDecoder.kanjiBankFileFormat, zip: zipFile) as [KanjiEntryV1]
        } else {
            termList = try readFileSequence(fileFormat: YomichanDictionaryDecoder.termBankFileFormat, zip: zipFile) as [TermEntryV3]
            kanjiList = try readFileSequence(fileFormat: YomichanDictionaryDecoder.kanjiBankFileFormat, zip: zipFile) as [KanjiEntryV3]
        }
        let termMetaList: [TermMetaEntry] = try readFileSequence(fileFormat: YomichanDictionaryDecoder.termMetaBankFileFormat, zip: zipFile)
        let kanjiMetaList: [KanjiMetaEntry] = try readFileSequence(fileFormat: YomichanDictionaryDecoder.kanjiMetaBankFileFormat, zip: zipFile)
        let tagList: [TagEntry] = try readFileSequence(fileFormat: YomichanDictionaryDecoder.tagBankFileFormat, zip: zipFile)

        return DecodedDictionary(index: index, termList: termList, termMetaList: termMetaList, kanjiList: kanjiList, kanjiMetaList: kanjiMetaList, tags: tagList)
    }

    private func importIndex(zip: Archive) throws -> DictionaryIndex {
        guard let indexFile = zip["index.json"] else {
            throw DictionaryDecoderError.indexNotFound
        }

        var data = Data()
        _ = try zip.extract(indexFile) { partData in
            data.append(partData)
        }

        let decoder = JSONDecoder()
        let index = try decoder.decode(DictionaryIndex.self, from: data)
        updateProgress()
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
            updateProgress()
        }
        return results
    }

    private func updateProgress() {
        let step = 1 / numberOfFiles
        currentProgress += step
        progress?(currentProgress)
    }
}
