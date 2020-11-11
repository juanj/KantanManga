//
//  ViewMangaCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import XCTest
@testable import Kantan_Manga

class ViewMangaCoordinatorTests: XCTestCase {

    func testStart_withEmptyNavigation_pushesMangaViewController() {
        let mockNavigation = FakeNavigation()
        let inMemoryData = InMemoryCoreDataManager()
        let manga = inMemoryData.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: mockNavigation, coreDataManager: inMemoryData, manga: manga!, delegate: FakeViewMangaCoordinatorDelegate(), originFrame: .zero, ocr: FakeImageOcr())

        viewMangaCoordinator.start()

        XCTAssertNotNil(mockNavigation.viewControllers.last as? MangaViewController)
    }
}
