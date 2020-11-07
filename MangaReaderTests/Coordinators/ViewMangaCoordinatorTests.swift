//
//  ViewMangaCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import XCTest
@testable import Kantan_Manga

class ViewMangaCoordinatorTests: XCTestCase {
    var navigation: Navigable!
    var delegate: MockViewMangaCoordinatorDelegate! // swiftlint:disable:this weak_delegate
    var viewMangaCoordinator: ViewMangaCoordinator!
    var ocr: MockOCR!
    var manga: Manga!

    /*override func setUp() {
        super.setUp()
        CoreDataManager.sharedManager.deleteAllData()
        navigation = MockNavigationController()
        delegate = MockViewMangaCoordinatorDelegate()
        ocr = MockOCR()
        manga = CoreDataManager.sharedManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 100, filePath: "test.cbz")!
        viewMangaCoordinator = ViewMangaCoordinator(navigation: navigation, manga: manga, delegate: delegate, originFrame: .zero, ocr: ocr)
    }

    func testCallingStartPushesViewController() {
        viewMangaCoordinator.start()
        XCTAssertNotNil(navigation.viewControllersTest.last as? MangaViewController)
    }

    // MARK: MangaViewControllerDelegate
    func testCallingDidTapTogglesFullscreen() {
        viewMangaCoordinator.start()
        guard let mangaView = navigation.viewControllersTest.first as? MangaViewController else {
            XCTAssertFalse(true)
            return
        }
        _ = mangaView.view // Load view
        XCTAssertTrue(mangaView.prefersStatusBarHidden)
        viewMangaCoordinator.didTapPage(mangaView, pageViewController: PageViewController(delegate: nil, pageSide: .center, pageNumber: 0))
        XCTAssertFalse(mangaView.prefersStatusBarHidden)
    }

    func testCallingBackPopsEndEnd() {
        viewMangaCoordinator.start()
        guard let mangaView = navigation.viewControllersTest.first as? MangaViewController else {
            XCTAssertFalse(true)
            return
        }
        XCTAssertTrue(navigation.viewControllersTest.count == 1)
        viewMangaCoordinator.back(mangaView)
        XCTAssertTrue(navigation.viewControllersTest.count == 0)
        XCTAssertTrue(delegate.didEndCalled)
    }

    func testCallingDidSelectSectionCallsOcr() {
        viewMangaCoordinator.start()
        guard let mangaView = navigation.viewControllersTest.first as? MangaViewController else {
            XCTAssertFalse(true)
            return
        }
        _ = mangaView.view // Load view
        let image = UIImage()
        viewMangaCoordinator.didSelectSectionOfImage(mangaView, image: image)
        XCTAssertEqual(ocr.image, image)
    }

    // MARK: UINavigationControllerDelegate
    func testCustomTransitionForPop() {
        var animation = viewMangaCoordinator.navigationController(navigation, animationControllerFor: .pop, from: UIViewController(), to: UIViewController())
        XCTAssertNil(animation)
        animation = viewMangaCoordinator.navigationController(navigation, animationControllerFor: .pop, from: CollectionViewController(delegate: MockCollectionViewControllerDelgate(), collection: MangaCollection(), sourcePoint: .zero, initialRotations: []), to: UIViewController())
        XCTAssertTrue(animation is OpenMangaAnimationController)
    }*/
}
