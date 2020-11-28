//
//  TermEntryV3Tests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class TermEntryV3Tests: XCTestCase {
    func testDecode_withOneGlossaryItem_decodesObject() throws {
        let json = #"["油かす", "あぶらかす", "n food", "", 5, ["deep-fried meat (esp. beef offal) resembling a pork rind"], 1695150, ""]"#
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term, TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: ["deep-fried meat (esp. beef offal) resembling a pork rind"], sequence: 1695150, termTags: ""))
    }

    func testDecode_withMultipleGlossaryItems_decodesObject() throws {
        let json = #"["油かす", "あぶらかす", "n food", "", 5, ["deep-fried meat (esp. beef offal) resembling a pork rind", "another1", "another2"], 1695150, ""]"#
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term, TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: ["deep-fried meat (esp. beef offal) resembling a pork rind", "another1", "another2"], sequence: 1695150, termTags: ""))
    }
}
