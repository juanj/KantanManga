//
//  BoolExtensionTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 15/11/20.
//

import XCTest
@testable import Kantan_Manga

class BoolExtensionTests: XCTestCase {
    func testIntValue_true_returns1() {
        let bool = true

        let intValue = bool.intValue

        XCTAssertEqual(intValue, 1)
    }

    func testIntValue_false_returns0() {
        let bool = false

        let intValue = bool.intValue

        XCTAssertEqual(intValue, 0)
    }
}
