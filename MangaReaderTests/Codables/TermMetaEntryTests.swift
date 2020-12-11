//
//  TermMetaEntryTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class TermMetaEntryTests: XCTestCase {
    func testDecode_withTypeFreqAndNumber_decodesObject() throws {
        let json = #"["打", "freq", 1]"#
        let decoder = JSONDecoder()

        let termMeta = try decoder.decode(TermMetaEntry.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(termMeta.description, TermMetaEntry(character: "打", mode: .freq(frequency: 1, reading: nil)).description)
    }

    func testDecode_withTypeFreqAndObject_decodesObject() throws {
        let json = #"["打", "freq", {"reading": "だ", "frequency": 4}]"#
        let decoder = JSONDecoder()

        let termMeta = try decoder.decode(TermMetaEntry.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(termMeta.description, TermMetaEntry(character: "打", mode: .freq(frequency: 4, reading: "だ")).description)
    }

    func testDecode_withTypePitch_decodesObject() throws {
        let json = """
        [
            "打ち込む",
            "pitch",
            {
                "reading": "うちこむ",
                "pitches": [
                    {"position": 0},
                    {"position": 3}
                ]
            }
        ]
        """
        let decoder = JSONDecoder()

        let termMeta = try decoder.decode(TermMetaEntry.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(termMeta.description, TermMetaEntry(character: "打ち込む", mode: .pitch(reading: "うちこむ", pitches: [.init(position: 0, tags: nil), .init(position: 3, tags: nil)])).description)
    }

    func testDecode_withTypePitchAndTags_decodesObject() throws {
        let json = """
        [
            "お手前",
            "pitch",
            {
                "reading": "おてまえ",
                "pitches": [
                    {"position": 2, "tags": ["ptag1"]},
                    {"position": 2, "tags": ["ptag2"]},
                    {"position": 0, "tags": ["ptag2"]}
                ]
            }
        ]
        """
        let decoder = JSONDecoder()

        let termMeta = try decoder.decode(TermMetaEntry.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(termMeta.description, TermMetaEntry(character: "お手前", mode: .pitch(reading: "おてまえ", pitches: [.init(position: 2, tags: ["ptag1"]), .init(position: 2, tags: ["ptag2"]), .init(position: 0, tags: ["ptag2"])])).description)
    }
}
