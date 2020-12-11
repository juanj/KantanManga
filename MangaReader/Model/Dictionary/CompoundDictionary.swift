//
//  CompoundDictionary.swift
//  MangaReader
//
//  Created by Juan on 10/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation
import GRDB

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
    case dictionaryIndexNotInserted
}

class CompoundDictionary {
    var isConnected: Bool {
        return db != nil
    }

    private var db: DatabaseQueue?

    private func connectTo(url: URL) throws -> DatabaseQueue {
        var configuration = Configuration()
        configuration.label = "Dictionaries"
        configuration.foreignKeysEnabled = true
        let db = try DatabaseQueue(path: url.path, configuration: configuration)
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
        let migrator = DBMigrator()
        try migrator.migrate(db: db)
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
            let count = try db.read { db in
                try Dictionary
                    .filter(Dictionary.Columns.title == title &&
                                Dictionary.Columns.revision == revision)
                    .fetchCount(db)
            }
            return count < 1
        } catch {
            return false
        }
    }

    func getDictionaries() throws -> [Dictionary] {
        guard let db = db else {
            throw DictionaryError.noConnection
        }

        return try db.read { db in
            try Dictionary.fetchAll(db)
        }
    }

    func addDictionary(_ decodedDictionary: DecodedDictionary) throws {
        guard let db = db else {
            throw DictionaryError.noConnection
        }

        // TODO: Insert DecodedDictionary

        var dictionary = Dictionary(from: decodedDictionary.index)
        try db.write { db in
            try dictionary.insert(db)
        }

        guard let dictionaryId = dictionary.id else {
            throw DictionaryError.dictionaryIndexNotInserted
        }

        // TODO: Save dictionary media
        try db.write { db in
            let terms = decodedDictionary
                .termList
                .map { Term(from: $0, dictionaryId: dictionaryId) }
            for var term in terms {
                try term.insert(db)
            }
        }

        try db.write { db in
            let termsMeta = decodedDictionary
                .termMetaList
                .map { TermMeta(from: $0, dictionaryId: dictionaryId) }
            for var termMeta in termsMeta {
                try termMeta.insert(db)
            }
        }

        try db.write { db in
            let kanjis = decodedDictionary
                .kanjiList
                .map { Kanji(from: $0, dictionaryId: dictionaryId) }
            for var kanji in kanjis {
                try kanji.insert(db)
            }
        }


        /*try db.transaction {
            for kanjiMeta in dictionary.kanjiMetaList {
                try DBRepresentation.KanjiMeta.insert(in: db, kanjiMeta: kanjiMeta, dictionary: dictionaryId)
            }

            for tag in dictionary.tags {
                try DBRepresentation.Tags.insert(in: db, tag: tag, dictionary: dictionaryId)
            }
        }*/
    }

    func deleteDictionary(id: Int) throws {
        guard let db = db else {
            throw DictionaryError.noConnection
        }

        // TODO: Delete dictionary
        /*try db.write { db in
            try Dictionary
                .filter(Dictionary.Columns.id == id)
                .deleteAll()
        }*/
    }

    func findTerm(term: String) throws -> [Term] {
        guard let db = db else {
            throw DictionaryError.noConnection
        }

        return try db.read { db in
            try Term
                .filter(Term.Columns.expression.like(term) || Term.Columns.reading.like(term))
                .fetchAll(db)
        }
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
