//
//  TermEntryV3Tests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class TermEntryV3Tests: XCTestCase {
    func testDecode_withOneStringGlossaryItem_decodesObject() throws {
        let json = #"["油かす", "あぶらかす", "n food", "", 5, ["deep-fried meat (esp. beef offal) resembling a pork rind"], 1695150, ""]"#
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term.description, TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: [.text("deep-fried meat (esp. beef offal) resembling a pork rind")], sequence: 1695150, termTags: "").description)
    }

    func testDecode_withMultipleStringGlossaryItems_decodesObject() throws {
        let json = #"["油かす", "あぶらかす", "n food", "", 5, ["deep-fried meat (esp. beef offal) resembling a pork rind", "another1", "another2"], 1695150, ""]"#
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term.description, TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: [.text("deep-fried meat (esp. beef offal) resembling a pork rind"), .text("another1"), .text("another2")], sequence: 1695150, termTags: "").description)
    }

    func testDecode_withOneTextObjectGlossaryItem_decodesObject() throws {
        let json = """
        [
            "油かす",
            "あぶらかす",
            "n food",
            "",
            5,
            [
                {
                    "type": "text",
                    "text": "deep-fried meat (esp. beef offal) resembling a pork rind"
                }
            ],
            1695150,
            ""
        ]
        """
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term.description, TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: [.text("deep-fried meat (esp. beef offal) resembling a pork rind")], sequence: 1695150, termTags: "").description)
    }

    func testDecode_withMultipleTextObjectGlossaryItems_decodesObject() throws {
        let json = """
        [
            "油かす",
            "あぶらかす",
            "n food",
            "",
            5,
            [
                {
                    "type": "text",
                    "text": "deep-fried meat (esp. beef offal) resembling a pork rind"
                },
                {
                    "type": "text",
                    "text": "another1"
                },
                {
                    "type": "text",
                    "text": "another2"
                }
            ],
            1695150,
            ""
        ]
        """
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term.description, TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: [.text("deep-fried meat (esp. beef offal) resembling a pork rind"), .text("another1"), .text("another2")], sequence: 1695150, termTags: "").description)
    }

    func testDecode_withOneImageObjectGlossaryItem_decodesObject() throws {
        let json = """
        [
            "油かす",
            "あぶらかす",
            "n food",
            "",
            5,
            [
                {
                    "type": "image",
                    "path": "test.png",
                    "width": 500,
                    "height": 250,
                    "title": "Test image",
                    "description": "A test image",
                    "pixelated": true
                }
            ],
            1695150,
            ""
        ]
        """
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term.description, TermEntryV3(expression: "油かす", reading: "あぶらかす", definitionTags: "n food", rules: "", score: 5, glossary: [.image(path: "test.png", width: 500, height: 250, title: "Test image", description: "A test image", pixelated: true)], sequence: 1695150, termTags: "").description)
    }

    func testDecode_withMixedImageAndTextObjects_decodesObject() throws {
        let json = """
        [
            "画像",
            "がぞう",
            "tag1 tag2",
            "",
            33,
            [
                "definition1a (画像, がぞう)",
                {
                    "type": "text",
                    "text": "another"
                },
                {
                    "type": "image",
                    "path": "image.gif",
                    "width": 350,
                    "height": 350,
                    "description": "An image",
                    "pixelated": true
                }
            ],
            7,
            "tag3 tag4 tag5"
        ]
        """
        let decoder = JSONDecoder()

        let term = try decoder.decode(TermEntryV3.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(term.description, TermEntryV3(expression: "画像", reading: "がぞう", definitionTags: "tag1 tag2", rules: "", score: 33, glossary: [.text("definition1a (画像, がぞう)"), .text("another"), .image(path: "image.gif", width: 350, height: 350, title: nil, description: "An image", pixelated: true)], sequence: 7, termTags: "tag3 tag4 tag5").description)
    }
}
