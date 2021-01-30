//
//  DictionaryTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 30/01/21.
//

import XCTest
import GRDB
@testable import Kantan_Manga

class DictionaryTests: XCTestCase {
    func testInit_fromDictionaryIndex_loadAllFields() {
        let index = DictionaryIndex(title: "Test", revision: "1", sequenced: false, format: .v1, version: nil, author: "Me", url: "url", description: "Test index", attribution: "Anyone")

        let dictionary = Dictionary(from: index)

        XCTAssertEqual([dictionary].description, #"[Kantan_Manga.Dictionary(id: nil, title: "Test", revision: "1", sequenced: Optional(false), version: 1, author: Optional("Me"), url: Optional("url"), description: Optional("Test index"), attribution: Optional("Anyone"))]"#)
    }

    func testInit_fromRow_loadAllFields() {
        let row = Row(["id": 0,
                        "title": "Test",
                       "revision": "1",
                       "sequenced": false,
                       "version": 1,
                       "author": "Me",
                       "url": "url",
                       "description": "Test index",
                       "attribution": "Anyone"])

        let dictionary = Dictionary(row: row)

        XCTAssertEqual([dictionary].description, #"[Kantan_Manga.Dictionary(id: Optional(0), title: "Test", revision: "1", sequenced: Optional(false), version: 1, author: Optional("Me"), url: Optional("url"), description: Optional("Test index"), attribution: Optional("Anyone"))]"#)
    }

    func testDidInsert_withRowId_setsRowId() {
        let index = DictionaryIndex(title: "Test", revision: "1", sequenced: false, format: .v1, version: nil, author: "Me", url: "url", description: "Test index", attribution: "Anyone")

        var dictionary = Dictionary(from: index)
        dictionary.didInsert(with: 5, for: nil)

        XCTAssertEqual(dictionary.id, 5)
    }
}
