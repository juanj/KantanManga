//
//  CompoundDictionaryTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 14/02/21.
//

@testable import Kantan_Manga
import XCTest
import GRDB

class CompoundDictionaryTests: XCTestCase {
    var db = TestsFactories.createTestDatabase()

    override func setUp() {
        // swiftlint:disable:next force_try
        try! db.write { db in
            try db.execute(sql: """
            INSERT INTO dictionaries (title, revision, version)
            VALUES ('Test', '1', 1)
            """)
            let dictionaryId = db.lastInsertedRowID
            try db.execute(sql: """
            INSERT INTO kanji (dictionaryId, character, onyomi, kunyomi, tags, meanings, stats)
            VALUES (\(dictionaryId), '試', '', '', '', '', ''),
                   (\(dictionaryId), '験', '', '', '', '', '')
            """)
            try db.execute(sql: """
            INSERT INTO terms (dictionaryId, expression, reading, rules, score, glossary, sequence, termTags)
            VALUES (\(dictionaryId), '試験', 'しけん', '', 0, '{"type": "text", "text": "examination; exam; test​"}', 0, '')
            """)
        }
    }

    override func tearDown() {
        // swiftlint:disable:next force_try
        try! db.write { db in
            try db.execute(sql: "DELETE FROM dictionaries")
        }
    }

    func testFindTerm_withExistingTerm_returnsMergedResults() throws {
        let term = "試験"
        let compoundDictionary = CompoundDictionary(db: db)

        let results = try compoundDictionary.findTerm(term)

        XCTAssertEqual(results.first?.expression, term)
    }

    func testFindKanjis_withMultiKanjiWord_returnsKanjis() throws {
        let word = "試験"
        let compoundDictionary = CompoundDictionary(db: db)

        let kanjis = try compoundDictionary.findKanji(word)

        XCTAssertEqual(kanjis.count, 2)
    }
}
