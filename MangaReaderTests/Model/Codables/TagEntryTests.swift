//
//  TagEntryTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 28/11/20.
//

import XCTest
@testable import Kantan_Manga

class TagEntryTests: XCTestCase {
    func testDecode_withValidJSON_decodesObject() throws {
        let json = #"["news", "frequent", -2, "appears frequently in Mainichi Shimbun", 0]"#
        let decoder = JSONDecoder()

        let tag = try decoder.decode(TagEntry.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(tag, TagEntry(name: "news", category: "frequent", order: -2, notes: "appears frequently in Mainichi Shimbun", score: 0))
    }
}
