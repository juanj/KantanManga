//
//  KanjiMetaTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 11/12/20.
//

import XCTest
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
}
