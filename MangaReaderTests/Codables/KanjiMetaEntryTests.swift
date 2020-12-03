//
//  KanjiMetaEntryTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class KanjiMetaEntryTests: XCTestCase {
    func testDecode_withFreqAndIntData_decodesObject() throws {
        let json = #"["打", "freq", 1]"#

        let decoder = JSONDecoder()
        let kanjiMeta = try decoder.decode(KanjiMetaEntry.self.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanjiMeta.description, KanjiMetaEntry(character: "打", category: .freq(1)).description)
    }

    func testDecode_withFreqAndStringData_decodesObject() throws {
        let json = #"["打", "freq", "1"]"#

        let decoder = JSONDecoder()
        let kanjiMeta = try decoder.decode(KanjiMetaEntry.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanjiMeta.description, KanjiMetaEntry(character: "打", category: .freq(1)).description)
    }

    func testCategoryEncode_freq_encodesCorrectly() throws {
        let freq = KanjiMetaEntry.Category.freq(1)
        let encoder = JSONEncoder()

        let encodedString = String(data: try encoder.encode(freq), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"type":"freq","frequency":1}"#)
    }

    func testCategoryDecode_freq_decodesObject() throws {
        let json = #"{"type":"freq","frequency":1}"#

        let decoder = JSONDecoder()
        let kanjiMetaCategory = try decoder.decode(KanjiMetaEntry.Category.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanjiMetaCategory.description, KanjiMetaEntry.Category.freq(1).description)
    }
}
