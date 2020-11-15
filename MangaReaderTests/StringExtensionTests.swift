//
//  StringExtensionTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 15/11/20.
//

import XCTest
@testable import Kantan_Manga

class StringExtensionTests: XCTestCase {
    func testLastPathComponent_withFilePathWithExtension_returnsFilaName() {
        let filePath = "/some/path/to/file.txt"

        let fileName = filePath.lastPathComponent

        XCTAssertEqual(fileName, "file.txt")
    }

    func testLastPathComponent_withFilePathWithoutExtension_returnsFilaName() {
        let filePath = "/some/path/to/file"

        let fileName = filePath.lastPathComponent

        XCTAssertEqual(fileName, "file")
    }

    func testLastPathComponent_fileName_returnsFilaName() {
        let filePath = "file.txt"

        let fileName = filePath.lastPathComponent

        XCTAssertEqual(fileName, "file.txt")
    }

    func testCapitalizingFirstLetter_withLowerCaseName_returnsSameStringWithFirstLetterUppercased() {
        let lowercaseString = "this is a string"

        let capitalizedString = lowercaseString.capitalizingFirstLetter()

        XCTAssertEqual(capitalizedString, "This is a string")
    }

    func testcapitalizeFirstLetter_withLowerCaseName_mutatesStringWithFirstLetterUppercased() {
        var lowercaseString = "this is a string"

        lowercaseString.capitalizeFirstLetter()

        XCTAssertEqual(lowercaseString, "This is a string")
    }
}
