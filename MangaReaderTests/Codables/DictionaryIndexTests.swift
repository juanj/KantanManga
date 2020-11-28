//
//  DictionaryIndexTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class DictionaryIndexTests: XCTestCase {
    func testDecode_withValidJSON_decodesObject() throws {
        let json = """
        {
          "title": "Test",
          "format": 3,
          "revision": "v1",
          "sequenced": true
        }
        """
        let decoder = JSONDecoder()

        let index = try decoder.decode(DictionaryIndex.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(index, DictionaryIndex(title: "Test", revision: "v1", sequenced: true, format: .v3, version: nil, author: nil, url: nil, description: nil, attribution: nil))
    }

    func testDecode_withFormatNumber_decodesObject() throws {
        let json = """
        {
          "title": "Test",
          "format": 1,
          "revision": "v1"
        }
        """
        let decoder = JSONDecoder()

        let index = try decoder.decode(DictionaryIndex.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(index, DictionaryIndex(title: "Test", revision: "v1", sequenced: nil, format: .v1, version: nil, author: nil, url: nil, description: nil, attribution: nil))
    }

    func testDecode_withVersionNumber_decodesObject() throws {
        let json = """
        {
          "title": "Test",
          "version": 3,
          "revision": "v3"
        }
        """
        let decoder = JSONDecoder()

        let index = try decoder.decode(DictionaryIndex.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(index, DictionaryIndex(title: "Test", revision: "v3", sequenced: nil, format: nil, version: .v3, author: nil, url: nil, description: nil, attribution: nil))
    }
}
