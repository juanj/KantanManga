//
//  KanjiTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 30/01/21.
//

import Foundation

import XCTest
import GRDB
@testable import Kantan_Manga

class KanjiTests: XCTestCase {
    func testInit_fromKanjiEntryV3_loadAllFields() {
        let entry = KanjiEntryV3(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: [], stats: [:])

        let kanji = Kanji(from: entry, dictionaryId: 0)

        XCTAssertEqual(kanji.description, "id: -1, dictionaryId: 0, character: 打, onyomi: ダ ダアス, kunyomi: う.つ う.ち- ぶ.つ, tags: ktag1 ktag2, meanings: [], stats: [:]")
    }

    func testInit_fromRow_loadAllFields() {
        let row = Row(["id": 0,
                       "dictionaryId": 0,
                       "character": "打",
                       "onyomi": "ダ ダアス",
                       "kunyomi": "う.つ う.ち- ぶ.つ",
                       "tags": "ktag1 ktag2",
                       "meanings": "",
                       "stats": ""])

        let kanji = Kanji(row: row)

        XCTAssertEqual(kanji.description, "id: 0, dictionaryId: 0, character: 打, onyomi: ダ ダアス, kunyomi: う.つ う.ち- ぶ.つ, tags: ktag1 ktag2, meanings: [], stats: [:]")
    }

    func testDidInsert_withRowId_setsRowId() {
        let entry = KanjiEntryV3(character: "打", onyomi: "ダ ダアス", kunyomi: "う.つ う.ち- ぶ.つ", tags: "ktag1 ktag2", meanings: [], stats: [:])

        var kanji = Kanji(from: entry, dictionaryId: 0)
        kanji.didInsert(with: 5, for: nil)

        XCTAssertEqual(kanji.id, 5)
    }
}
