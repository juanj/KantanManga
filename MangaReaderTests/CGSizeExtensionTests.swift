//
//  CGSizeExtensionTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 15/11/20.
//

import XCTest
@testable import Kantan_Manga

class CGSizeExtensionTests: XCTestCase {
    func testAspectFit_withSquareSize_keepsProportion() {
        let originalSize = CGSize(width: 100, height: 100)

        let aspectFitSize = CGSize.aspectFit(size: originalSize, inside: CGSize(width: 50, height: 50))

        XCTAssertEqual(aspectFitSize.width, aspectFitSize.height)
    }

    func testAspectFit_withRectangleSize_keepsProportion() {
        let originalSize = CGSize(width: 50, height: 100)

        let aspectFitSize = CGSize.aspectFit(size: originalSize, inside: CGSize(width: 50, height: 50))

        XCTAssertEqual(aspectFitSize.width * 2, aspectFitSize.height)
    }

    func testAspectFit_withSquareSize_widthFitsInsideNewSize() {
        let originalSize = CGSize(width: 100, height: 100)
        let fitSize = CGSize(width: 50, height: 50)

        let aspectFitSize = CGSize.aspectFit(size: originalSize, inside: fitSize)

        XCTAssertLessThanOrEqual(aspectFitSize.width, fitSize.width)
    }

    func testAspectFit_withSquareSize_heightFitsInsideNewSize() {
        let originalSize = CGSize(width: 100, height: 100)
        let fitSize = CGSize(width: 50, height: 50)

        let aspectFitSize = CGSize.aspectFit(size: originalSize, inside: fitSize)

        XCTAssertLessThanOrEqual(aspectFitSize.height, fitSize.height)
    }

    func testAspectFit_withRectangleSize_widthFitsInsideNewSize() {
        let originalSize = CGSize(width: 50, height: 100)
        let fitSize = CGSize(width: 50, height: 50)

        let aspectFitSize = CGSize.aspectFit(size: originalSize, inside: fitSize)

        XCTAssertLessThanOrEqual(aspectFitSize.width, fitSize.width)
    }

    func testAspectFit_withRectangleSize_heightFitsInsideNewSize() {
        let originalSize = CGSize(width: 50, height: 100)
        let fitSize = CGSize(width: 50, height: 50)

        let aspectFitSize = CGSize.aspectFit(size: originalSize, inside: fitSize)

        XCTAssertLessThanOrEqual(aspectFitSize.height, fitSize.height)
    }
}
