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
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: mockNavigation, coreDataManager: FakeCoreDataManager(), manga: Manga(), delegate: FakeViewMangaCoordinatorDelegate(), originFrame: .zero, ocr: FakeImageOcr())
        viewMangaCoordinator.start()
        XCTAssertNotNil(mockNavigation.viewControllers.last as? MangaViewController)
    }

    // MARK: MangaViewControllerDelegate
    func testMangaViewControllerDelegateDidTap_togglesFullscreen() {
        let stubNavigation = FakeNavigation()
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: stubNavigation, coreDataManager: FakeCoreDataManager(), manga: Manga(), delegate: FakeViewMangaCoordinatorDelegate(), originFrame: .zero, ocr: FakeImageOcr())
        viewMangaCoordinator.start()

        guard let mangaView = stubNavigation.viewControllers.last as? MangaViewController else {
            XCTAssertTrue(false)
            return
        }
        _ = mangaView // Load view

        viewMangaCoordinator.didTapPage(mangaView, pageViewController: PageViewController(delegate: nil, pageSide: .center, pageNumber: 0))

        XCTAssertFalse(mangaView.prefersStatusBarHidden)
    }
}
