//
//  SequenceExtensionTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 14/02/21.
//

@testable import Kantan_Manga
import XCTest

class SequenceExtensionTests: XCTestCase {
    private struct TestObject: Equatable {
        let id: Int
        let name: String
    }

    func testKeyedBy_withValidKeyPath_mapsToDictionary() {
        let values = [TestObject(id: 1, name: "test"), TestObject(id: 2, name: "test 2"), TestObject(id: 3, name: "test 3")]

        let maped = values.keyedBy(\.name)

        XCTAssertEqual(maped, ["test": TestObject(id: 1, name: "test"), "test 2": TestObject(id: 2, name: "test 2"), "test 3": TestObject(id: 3, name: "test 3")])
    }
}
