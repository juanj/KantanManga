//
//  KanjiMetaTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 11/12/20.
//

import XCTest
import GRDB
@testable import Kantan_Manga

class KanjiMetaTests: XCTestCase {
    func testCategoryEncode_freq_encodesCorrectly() throws {
        let freq = KanjiMeta.Category.freq(1)
        let encoder = JSONEncoder()

        let encodedString = String(data: try encoder.encode(freq), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"type":"freq","frequency":1}"#)
    }

    func testCategoryDecode_freq_decodesObject() throws {
        let json = #"{"type":"freq","frequency":1}"#

        let decoder = JSONDecoder()
        let kanjiMetaCategory = try decoder.decode(KanjiMeta.Category.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanjiMetaCategory.description, KanjiMeta.Category.freq(1).description)
    }

    func testCategoryDecode_withInvalidType_defaultsToFreq0() throws {
        let json = #"{"type":"nofreq","frequency":1}"#

        let decoder = JSONDecoder()
        let kanjiMetaCategory = try decoder.decode(KanjiMeta.Category.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanjiMetaCategory.description, KanjiMeta.Category.freq(0).description)
    }

    func testInit_fromKanjiMetaEntry_loadAllFields() {
        let entry = KanjiMetaEntry(character: "打", category: .freq(0))

        let kanjiMeta = KanjiMeta(from: entry, dictionaryId: 0)

        XCTAssertEqual(kanjiMeta.description, "id: -1, dictionaryId: 0, character: 打, category: freq 0")
    }

    func testInit_fromRow_loadAllFields() {
        let row = Row(["id": 0,
                       "dictionaryId": 0,
                       "character": "打",
                       "category": #"{"type": "freq", "frequency": 0}"#])

        let kanjiMeta = KanjiMeta(row: row)

        XCTAssertEqual(kanjiMeta.description, "id: 0, dictionaryId: 0, character: 打, category: freq 0")
    }

    func testDidInsert_withRowId_setsRowId() {
        let entry = KanjiMetaEntry(character: "打", category: .freq(0))

        var kanjiMeta = KanjiMeta(from: entry, dictionaryId: 0)
        kanjiMeta.didInsert(with: 5, for: nil)

        XCTAssertEqual(kanjiMeta.id, 5)
    }
}
