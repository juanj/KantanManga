//
//  KanjiEntryV1Tests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class KanjiEntryV1Tests: XCTestCase {
    func testDecode_withNoMeanings_decodesObject() throws {
        let json = #"["打", "ダ ダアス", "う.つ う.ち- ぶ.つ", "ktag1 ktag2"]"#

        let decoder = JSONDecoder()
        let kanji = try decoder.decode(KanjiEntryV1.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanji.description, KanjiEntryV1(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: []).description)
    }

    func testDecode_withOneMeaning_decodesObject() throws {
        let json = #"["打", "ダ ダアス", "う.つ う.ち- ぶ.つ", "ktag1 ktag2", "meaning"]"#

        let decoder = JSONDecoder()
        let kanji = try decoder.decode(KanjiEntryV1.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanji.description, KanjiEntryV1(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: ["meaning"]).description)
    }

    func testDecode_withMultipleMeanings_decodesObject() throws {
        let json = #"["打", "ダ ダアス", "う.つ う.ち- ぶ.つ", "ktag1 ktag2", "meaning1", "meaning2", "meaning3"]"#

        let decoder = JSONDecoder()
        let kanji = try decoder.decode(KanjiEntryV1.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanji.description, KanjiEntryV1(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: ["meaning1", "meaning2", "meaning3"]).description)
    }
}
