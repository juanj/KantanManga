//
//  TermEntryV1Tests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class TermEntryV1Tests: XCTestCase {
    func testDecode_withOneGlossaryItem_decodesObject() throws {
        let json = #"["油かす", "あぶらかす", "n food", "", 5, "deep-fried meat (esp. beef offal) resembling a pork rind"]"#
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV1.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term, TermEntryV1(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: ["deep-fried meat (esp. beef offal) resembling a pork rind"]))
    }

    func testDecode_withMultipleGlossaryItems_decodesObject() throws {
        let json = #"["油かす", "あぶらかす", "n food", "", 5, "deep-fried meat (esp. beef offal) resembling a pork rind", "another1", "another2"]"#
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV1.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term, TermEntryV1(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: ["deep-fried meat (esp. beef offal) resembling a pork rind", "another1", "another2"]))
    }
}
