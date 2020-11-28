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
}
