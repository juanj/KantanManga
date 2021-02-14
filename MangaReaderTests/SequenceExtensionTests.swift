//
//  SequenceExtensionTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 14/02/21.
//

@testable import Kantan_Manga
import XCTest

class SequenceExtensionTests: XCTestCase {
    func testKeyedBy_withValidKeyPath_mapsToDictionary() {
        let values = [(id: 1, name: "test"), (id: 2, name: "test 2"), (id: 3, name: "test 3")]

        let maped = values.keyedBy(\.name)

        XCTAssertEqual(maped.description, ["test": (id: 1, name: "test"), "test 2": (id: 2, name: "test 2"), "test 3": (id: 3, name: "test 3")].description)
    }
}
