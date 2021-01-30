//
//  GlossaryItemTests.swift
//  Kantan-Manga
//
//  Created by Juan on 30/01/21.
//

import XCTest
@testable import Kantan_Manga

class GlossaryItemTests: XCTestCase {
    func testDecode_typeText_decodesObject() throws {
        let json = #"{"type": "text", "text": "test"}"#

        let decoder = JSONDecoder()
        let glossaryItem = try decoder.decode(GlossaryItem.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(glossaryItem.description, GlossaryItem.text("test").description)
    }

    func testDecode_typeImage_decodesObject() throws {
        let json = #"{"type": "image", "path": "test.png", "width": 100, "height": 100, "title": "Test image", "description": "An image", "pixelated": true}"#

        let decoder = JSONDecoder()
        let glossaryItem = try decoder.decode(GlossaryItem.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(glossaryItem.description, GlossaryItem.image(path: "test.png", width: 100, height: 100, title: "Test image", description: "An image", pixelated: true).description)
    }

    func testDecode_typeImageWithoutPixelated_defaultsToFalse() throws {
        let json = #"{"type": "image", "path": "test.png"}"#

        let decoder = JSONDecoder()
        let glossaryItem = try decoder.decode(GlossaryItem.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(glossaryItem.description, GlossaryItem.image(path: "test.png", width: nil, height: nil, title: nil, description: nil, pixelated: false).description)
    }

    func testDecode_withInvalidType_defaultsToEmptyText() throws {
        let json = #"{"type": "noimage"}"#

        let decoder = JSONDecoder()
        let glossaryItem = try decoder.decode(GlossaryItem.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(glossaryItem.description, GlossaryItem.text("").description)
    }

    func testEncode_typeText_encodesObject() throws {
        let glossaryItem = GlossaryItem.text("This is a text")

        let encoder = JSONEncoder()
        let encodedString = String(data: try encoder.encode(glossaryItem), encoding: .utf8) ?? ""

        XCTAssertEqual(encodedString, #"{"type":"text","text":"This is a text"}"#)
    }

    func testEncode_typeImage_encodedObjectDecodesToSameObject() throws {
        let glossaryItem = GlossaryItem.image(path: "test.svg", width: 100, height: 120, title: "Test image", description: "An image", pixelated: false)

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(glossaryItem)
        let decoder = JSONDecoder()
        let decodedGlossaryItem = try decoder.decode(GlossaryItem.self, from: encodedData)

        XCTAssertEqual(decodedGlossaryItem.description, glossaryItem.description)
    }
}
