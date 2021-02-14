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
            try db.execute(sql: """
            INSERT INTO kanji (dictionaryId, character, onyomi, kunyomi, tags, meanings, stats)
            VALUES (\(db.lastInsertedRowID), '試', '', '', '', '', ''),
                   (\(db.lastInsertedRowID), '験', '', '', '', '', '')
            """)
        }
    }

    func testFindKanjis_withMultiKanjiWord_returnKanjis() throws {
        let word = "試験"
        let compoundDictionary = CompoundDictionary(db: db)

        let kanjis = try compoundDictionary.findKanji(word)

        XCTAssertEqual(kanjis.count, 2)
    }
}
