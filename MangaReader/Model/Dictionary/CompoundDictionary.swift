//
//  CompoundDictionary.swift
//  MangaReader
//
//  Created by Juan on 10/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation
import SQLite

struct DictionaryResult {
    let term: String
    let reading: String
    var meanings: [GlossaryItem]
}

enum DictionaryError: Error {
    case canNotGetLibraryURL
    case dictionaryAlreadyExists
    case noConnection
    case dbFileNotFound
}

class CompoundDictionary {
    var isConnected: Bool {
        return db != nil
    }

    private var db: Connection?

    private func connectTo(url: URL) throws -> Connection {
        let db = try Connection(url.path)
        try db.execute("PRAGMA foreign_keys = ON;")
        return db
    }

    func connectToDataBase(fileName: String = "dic.db", fileManager: FileManager = .default) throws {
        guard let libraryUrl = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw DictionaryError.canNotGetLibraryURL
        }

        let dbUrl = libraryUrl.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: dbUrl.path) else {
            throw DictionaryError.dbFileNotFound
        }

        db = try connectTo(url: dbUrl)
    }

    func createDataBase(fileName: String = "dic.db", fileManager: FileManager = .default) throws {
        guard let libraryUrl = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw DictionaryError.canNotGetLibraryURL
        }

        let dbUrl = libraryUrl.appendingPathComponent(fileName)
        guard !fileManager.fileExists(atPath: dbUrl.path) else {
            throw DictionaryError.dictionaryAlreadyExists
        }

        let db = try connectTo(url: dbUrl)
        try DBRepresentation.Dictionaries.createTable(in: db)
        try DBRepresentation.Kanji.createTable(in: db)
        try DBRepresentation.KanjiMeta.createTable(in: db)
        try DBRepresentation.Terms.createTable(in: db)
        try DBRepresentation.TermsMeta.createTable(in: db)
        try DBRepresentation.Tags.createTable(in: db)
        self.db = db
    }

    func removeDataBase(fileName: String = "dic.db", fileManager: FileManager = .default) throws {
        guard let libraryUrl = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw DictionaryError.canNotGetLibraryURL
        }

        let dbUrl = libraryUrl.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: dbUrl.path) else {
            throw DictionaryError.dbFileNotFound
        }

        try fileManager.removeItem(at: dbUrl)
    }

    func dictionaryExists(title: String, revision: String) throws -> Bool {
        guard let db = db else {
            throw DictionaryError.noConnection
        }
        do {
            let count = try db.scalar(
                DBRepresentation.Dictionaries.table.filter(
                    DBRepresentation.Dictionaries.title == title &&
                        DBRepresentation.Dictionaries.revision == revision
                ).count
            )
            return count < 1
        } catch {
            return false
        }
    }

    func getDictionaries() throws -> [DictionaryIndex] {
        guard let db = db else {
            throw DictionaryError.noConnection
        }

        var dictionaries = [DictionaryIndex]()
        for row in try db.prepare(DBRepresentation.Dictionaries.table) {
            if let dictionary = DBRepresentation.Dictionaries.toDictionaryIndex(row) {
                dictionaries.append(dictionary)
            }
        }

        return dictionaries
    }

    func addDictionary(_ dictionary: Dictionary) throws {
        guard let db = db else {
            throw DictionaryError.noConnection
        }
        try db.transaction {
            // TODO: Save dictionary media
            let dictionaryId = try DBRepresentation.Dictionaries.insert(in: db, index: dictionary.index)
            for term in dictionary.termList {
                try DBRepresentation.Terms.insert(in: db, term: term, dictionary: dictionaryId)
            }

            for termMeta in dictionary.termMetaList {
                try DBRepresentation.TermsMeta.insert(in: db, termMeta: termMeta, dictionary: dictionaryId)
            }

            for kanji in dictionary.kanjiList {
                try DBRepresentation.Kanji.insert(in: db, kanji: kanji, dictionary: dictionaryId)
            }

            for kanjiMeta in dictionary.kanjiMetaList {
                try DBRepresentation.KanjiMeta.insert(in: db, kanjiMeta: kanjiMeta, dictionary: dictionaryId)
            }

            for tag in dictionary.tags {
                try DBRepresentation.Tags.insert(in: db, tag: tag, dictionary: dictionaryId)
            }
        }
    }

    func deleteDictionary(id: Int64) throws {
        guard let db = db else {
            throw DictionaryError.noConnection
        }

        try db.run(DBRepresentation.Dictionaries.deleteQuery(id: id).delete())
    }

    func findTerm(term: String) throws -> [DictionaryResult] {
        guard let db = db else {
            throw DictionaryError.noConnection
        }

        var results = [DictionaryResult]()
        for term in try db.prepare(DBRepresentation.Terms.searchQuery(term: term)) {
            if let entry = DBRepresentation.Terms.toDictionaryResult(term) {
                results.append(entry)
            }
        }

        return mergeResults(results)
    }

    private func mergeResults(_ results: [DictionaryResult]) -> [DictionaryResult] {
        var mergedResults = [DictionaryResult]()

        for result in results {
            if let entryIndex = mergedResults.firstIndex(where: { $0.reading == result.reading && $0.term == result.term }) {
                mergedResults[entryIndex].meanings += result.meanings
            } else {
                mergedResults.append(result)
            }
        }

        return mergedResults
    }
}
