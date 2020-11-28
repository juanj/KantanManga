//
//  KanjiEntryV3Tests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class KanjiEntryV3Tests: XCTestCase {
    func testDecode_withoutMeanings_decodesObject() throws {
        let json = """
        [
            "打",
            "ダ ダアス",
            "う.つ う.ち- ぶ.つ",
            "ktag1 ktag2",
            [],
            {}
        ]
        """

        let decoder = JSONDecoder()
        let kanji = try decoder.decode(KanjiEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanji.description, KanjiEntryV3(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: [], stats: [:]).description)
    }

    func testDecode_withMultipleMeanings_decodesObject() throws {
        let json = """
        [
            "打",
            "ダ ダアス",
            "う.つ う.ち- ぶ.つ",
            "ktag1 ktag2",
            [
                "meaning1",
                "meaning2",
                "meaning3",
                "meaning4",
                "meaning5",
                "meaning6"
            ],
            {}
        ]
        """

        let decoder = JSONDecoder()
        let kanji = try decoder.decode(KanjiEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanji.description, KanjiEntryV3(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: ["meaning1", "meaning2", "meaning3", "meaning4", "meaning5", "meaning6"], stats: [:]).description)
    }

    func testDecode_withMultipleMeaningsAndStats_decodesObject() throws {
        let json = """
        [
            "打",
            "ダ ダアス",
            "う.つ う.ち- ぶ.つ",
            "ktag1 ktag2",
            [
                "meaning1",
                "meaning2",
                "meaning3",
                "meaning4",
                "meaning5",
                "meaning6"
            ],
            {
                "stat1": "value1",
                "stat2": "value2"
            }
        ]
        """

        let decoder = JSONDecoder()
        let kanji = try decoder.decode(KanjiEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(kanji.description, KanjiEntryV3(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: ["meaning1", "meaning2", "meaning3", "meaning4", "meaning5", "meaning6"], stats: ["stat1": "value1", "stat2": "value2"]).description)
    }
}
