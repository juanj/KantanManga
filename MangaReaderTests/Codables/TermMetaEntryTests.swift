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

    func testPitchAccentEncode_withPosition_encodesCorrectly() throws {
        let pitch = TermMetaEntry.PitchAccent(position: 0, tags: nil)
        let encoder = JSONEncoder()

        let encodedString = String(data: try encoder.encode(pitch), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"position":0}"#)
    }

    func testPitchAccentEncode_withPositionAndTags_encodesCorrectly() throws {
        let pitch = TermMetaEntry.PitchAccent(position: 0, tags: ["1", "2"])
        let encoder = JSONEncoder()

        let encodedString = String(data: try encoder.encode(pitch), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"position":0,"tags":["1","2"]}"#)
    }

    func testModeEncode_freqWithoutReading_encodesCorrectly() throws {
        let freq = TermMetaEntry.Mode.freq(frequency: 1, reading: nil)
        let encoder = JSONEncoder()

        let encodedString = String(data: try encoder.encode(freq), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"type":"freq","frequency":1}"#)
    }

    func testModeEncode_freqWithReading_encodesCorrectly() throws {
        let freq = TermMetaEntry.Mode.freq(frequency: 1, reading: "1")
        let encoder = JSONEncoder()

        let encodedString = String(data: try encoder.encode(freq), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"type":"freq","reading":"1","frequency":1}"#)
    }

    func testModeEncode_pitch_encodesCorrectly() throws {
        let pitch = TermMetaEntry.Mode.pitch(reading: "1", pitches: [.init(position: 0, tags: nil)])
        let encoder = JSONEncoder()

        let encodedString = String(data: try encoder.encode(pitch), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"type":"pitch","reading":"1","pitches":[{"position":0}]}"#)
    }
}
