//
//  Kantan_MangaIntegrationTests.swift
//  Kantan MangaIntegrationTests
//
//  Created by Juan on 10/11/20.
//

import XCTest
@testable import Kantan_Manga

class CoreDataManagerIntegrationTests: XCTestCase {
    // If the target containing this test is run directly, it passed. But if is run after the other target, it throws a "File not found error"
    /*func testCreateDemoManga_createsDemoManga() {
        let coreDataManager = InMemoryCoreDataManager()
        let expectation = XCTestExpectation(description: "Demo manga is copied from bundle and is inserted")
        coreDataManager.createDemoManga {
            let manga = coreDataManager.getMangaWith(filePath: "demo1.cbz")
            XCTAssertNotNil(manga)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }*/
}
