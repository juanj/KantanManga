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
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(navigable: mockNavigation)

        viewMangaCoordinator.start()

        XCTAssertNotNil(mockNavigation.viewControllers.last as? MangaViewController)
    }

    func testStart_withEmptyUserDefaults_setsHasSeenMangaToTrue() {
        UserDefaults.resetStandardUserDefaults()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator()

        viewMangaCoordinator.start()

        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasSeenManga"))
    }

    // MARK: MangaViewControllerDelegate
    func testMangaViewControllerDelegateDidTapPage_withFullScreenFalse_setsFullScreenTrue() {
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator()
        let mockMangaViewController = TestsFactories.createMangaViewController(firstTime: true)

        _ = mockMangaViewController.view
        viewMangaCoordinator.didTapPage(mockMangaViewController, pageViewController: PageViewController(delegate: nil, pageSide: .center, pageNumber: 0))

        XCTAssertTrue(mockMangaViewController.prefersStatusBarHidden)
    }

    func testMangaViewControllerDelegateBack_withViewControllerOnNavigationStack_popsViewController() {
        let mockNavigation = FakeNavigation()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(navigable: mockNavigation)

        mockNavigation.pushViewController(UIViewController(), animated: false)
        viewMangaCoordinator.back(TestsFactories.createMangaViewController())

        XCTAssertEqual(mockNavigation.viewControllers.count, 0)
    }

    func testMangaViewControllerDelegateDidSelectSectionOfImage_withEmptyImage_callsRecognizeOnOCR() {
        let mockOCR = FakeImageOcr()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(ocr: mockOCR)
        let mangaViewController = TestsFactories.createMangaViewController()

        _ = mangaViewController.view
        let image = UIImage(systemName: "0.circle.fill")!
        viewMangaCoordinator.didSelectSectionOfImage(TestsFactories.createMangaViewController(), image: image)

        XCTAssertTrue(mockOCR.recognizeCalls.contains(image))
    }

    func testMangaViewControllerDelegateDidTapSettings_withoutPresentedViewController_presentsViewcontroller() {
        let mockNavigation = FakeNavigation()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(navigable: mockNavigation)

        viewMangaCoordinator.didTapSettings(TestsFactories.createMangaViewController())

        XCTAssertNotNil(mockNavigation.presentedViewController)
    }

    func testMangaViewControllerDelegatePageDidChange_withCurrentPageAt0_setsCorrectPage() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let manga = mockCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 10, filePath: "")!
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(coreDataManager: mockCoreDataManager, manga: manga)

        viewMangaCoordinator.pageDidChange(TestsFactories.createMangaViewController(), manga: manga, newPage: 5)

        XCTAssertEqual(mockCoreDataManager.fetchAllMangas()?.first?.currentPage, 5)
    }
}
