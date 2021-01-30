//
//  TermTests.swift
//  Kantan-Manga
//
//  Created by Juan on 30/01/21.
//

import XCTest
import GRDB
@testable import Kantan_Manga

class TermTests: XCTestCase {
    func testInit_fromTermEntryV3_loadAllFields() {
        let termEntry = TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: [.text("deep-fried meat (esp. beef offal) resembling a pork rind")], sequence: 1695150, termTags: "")

        let term = Term(from: termEntry, dictionaryId: 0)

        XCTAssertEqual(term.description, "id: -1, dictionaryId: 0, expression: 油かす, reading: あぶらかす, definitionTags: n food, rules: , score: 5, glossary: [deep-fried meat (esp. beef offal) resembling a pork rind], sequence: 1695150, termTags: ")
    }

    func testInit_fromRow_loadAllFields() {
        let row = Row(["dictionaryId": 0,
                        "expression": "油かす",
                       "reading": "あぶらかす",
                       "definitionTags": "n food",
                       "rules": "", "score": 5,
                       "glossary": #"[{"type": "text", "text": "deep-fried meat (esp. beef offal) resembling a pork rind"}]"#, "sequence": 1695150, "termTags": ""])

        let term = Term(row: row)

        XCTAssertEqual(term.description, "id: -1, dictionaryId: 0, expression: 油かす, reading: あぶらかす, definitionTags: n food, rules: , score: 5, glossary: [deep-fried meat (esp. beef offal) resembling a pork rind], sequence: 1695150, termTags: ")
    }

    func testDidInsert_withRowId_setsRowId() {
        let termEntry = TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: [.text("deep-fried meat (esp. beef offal) resembling a pork rind")], sequence: 1695150, termTags: "")

        var term = Term(from: termEntry, dictionaryId: 0)
        term.didInsert(with: 5, for: nil)

        XCTAssertEqual(term.id, 5)
    }
}
