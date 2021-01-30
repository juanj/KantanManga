//
//  TermMetaTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 11/12/20.
//

import XCTest
@testable import Kantan_Manga

class TermMetaTests: XCTestCase {
    func testPitchAccentEncode_withPosition_encodesCorrectly() throws {
            let pitch = TermMeta.PitchAccent(position: 0, tags: nil)
            let encoder = JSONEncoder()

            let encodedString = String(data: try encoder.encode(pitch), encoding: .utf8) ?? ""

            XCTAssertEqual(encodedString, #"{"position":0}"#)
        }

        func testPitchAccentEncode_withPositionAndTags_encodesCorrectly() throws {
            let pitch = TermMeta.PitchAccent(position: 0, tags: ["1", "2"])
            let encoder = JSONEncoder()

            let encodedString = String(data: try encoder.encode(pitch), encoding: .utf8) ?? ""

            XCTAssertEqual(encodedString, #"{"position":0,"tags":["1","2"]}"#)
        }

        func testModeEncode_freqWithoutReading_encodesCorrectly() throws {
            let freq = TermMeta.Mode.freq(frequency: 1, reading: nil)
            let encoder = JSONEncoder()

            let encodedString = String(data: try encoder.encode(freq), encoding: .utf8) ?? ""

            XCTAssertEqual(encodedString, #"{"type":"freq","frequency":1}"#)
        }

        func testModeEncode_freqWithReading_encodesCorrectly() throws {
            let freq = TermMeta.Mode.freq(frequency: 1, reading: "1")
            let encoder = JSONEncoder()

            let encodedString = String(data: try encoder.encode(freq), encoding: .utf8) ?? ""

            XCTAssertEqual(encodedString, #"{"type":"freq","reading":"1","frequency":1}"#)
        }

        func testModeEncode_pitch_encodesCorrectly() throws {
            let pitch = TermMeta.Mode.pitch(reading: "1", pitches: [.init(position: 0, tags: nil)])
            let encoder = JSONEncoder()

            let encodedString = String(data: try encoder.encode(pitch), encoding: .utf8) ?? ""

            XCTAssertEqual(encodedString, #"{"type":"pitch","reading":"1","pitches":[{"position":0}]}"#)
        }
}
