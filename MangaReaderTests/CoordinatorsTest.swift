//
//  CoordinatorsTest.swift
//  MangaReaderTests
//
//  Created by Juan on 29/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import XCTest
@testable import Kantan_Manga

class AppCoordinatorTests: XCTestCase {
    var navigation: MockNavigationController!
    var appCoordinator: AppCoordinator!

    override func setUp() {
        super.setUp()
        CoreDataManager.sharedManager.deleteAllData()
        navigation = MockNavigationController()
        appCoordinator = AppCoordinator(navigation: navigation)
    }

    func testCallingStartPushLibraryViewController() {
        appCoordinator.start()
        XCTAssertTrue(navigation.viewControllersTest.first is LibraryViewController)
    }

    func testLoadCollectionsWithMangas() {
        XCTAssertNotNil(appCoordinator.loadCollections())
        let collection = CoreDataManager.sharedManager.insertCollection(name: "Test Collection")
        XCTAssertEqual(appCoordinator.loadCollections().count, 0)
        CoreDataManager.sharedManager.insertManga(name: "Test", coverData: Data(), totalPages: 5, filePath: "test.cbz", collection: collection)
        XCTAssertEqual(appCoordinator.loadCollections().count, 1)
    }

    // MARK: LibraryViewControllerDelegate
    func testLibraryDelegateSelectAddStartCoordinator() {
        let delegate = DummyLibraryViewControllerDelegate()
        let libraryViewController = MockLibraryViewController(delegate: delegate, collections: [])

        appCoordinator.didSelectAdd(libraryViewController, button: UIBarButtonItem())

        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertNotNil(appCoordinator.childCoordinators.first as? AddMangasCoordinator)
    }

    // MARK: AddMangasCoordinatorDelegate
    func testAddMangaDelegateEndRemoveCoordinator() {
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: MockUploadServer(), delegate: appCoordinator)
        appCoordinator.childCoordinators.append(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        appCoordinator.didEnd(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }

    func testAddMangaDelegateCancelRemoveCoordinator() {
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: MockUploadServer(), delegate: appCoordinator)
        appCoordinator.childCoordinators.append(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        appCoordinator.cancel(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }

    // MARK: CollectionViewControllerDelegate
    func testCollectionDelegateSelectMangaStartCoordinator() {
        let manga = CoreDataManager.sharedManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 100, filePath: "test.cbz")!
        let libraryViewController = MockCollectionViewController(delegate: MockCollectionViewControllerDelgate(), collection: MangaCollection(), sourcePoint: .zero, initialRotations: [])

        appCoordinator.didSelectManga(libraryViewController, manga: manga, cellFrame: .zero)

        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertNotNil(appCoordinator.childCoordinators.first as? ViewMangaCoordinator)
    }

}

class AddMangasCoordinatorTests: XCTestCase {
    var navigation: MockNavigationController!
    var delegate: MockAddMangasCoordinatorDelegate! // swiftlint:disable:this weak_delegate
    var mockServer: MockUploadServer!
    var addMangasCoordinator: AddMangasCoordinator!

    override func setUp() {
        super.setUp()
        CoreDataManager.sharedManager.deleteAllData()
        navigation = MockNavigationController()
        delegate = MockAddMangasCoordinatorDelegate()
        mockServer = MockUploadServer()
        addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: mockServer, delegate: delegate)
    }

    func testCallingStarPresentsNavigationWithAddMangaViewController() {
        addMangasCoordinator.start()
        XCTAssertTrue((navigation.presentedViewControllerTest as? UINavigationController)?.viewControllers.first is AddMangaViewController)
    }

    // MARK: GCDWebUploaderDelegate
    func testUploaderDelegateCallingDidUploadStopsServer() {
        addMangasCoordinator.webUploader(mockServer, didUploadFileAtPath: "")
        XCTAssertTrue(mockServer.stopCalled)
    }

    func testUploaderDelegateCallingDidDeleteRemovesManga() {
        let manga = CoreDataManager.sharedManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 100, filePath: "test.cbz")!
        XCTAssertEqual(CoreDataManager.sharedManager.fetchAllMangas(), [manga])
        addMangasCoordinator.webUploader(mockServer, didDeleteItemAtPath: "test.cbz")
        XCTAssertEqual(CoreDataManager.sharedManager.fetchAllMangas(), [])
    }

    // MARK: WebServerViewControllerDelegate
    func testWebServerDelegateCallingDidSelectBackStopsServer() {
        addMangasCoordinator.didSelectBack(WebServerViewController())
        XCTAssertTrue(mockServer.stopCalled)
    }

    // MARK: AddMangaViewControllerDelegate
    func testAddMangaDelegateCallingCancelDismissAndCancels() {
        addMangasCoordinator.cancel(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))
        XCTAssertTrue(delegate.cancelCalled)
        XCTAssertTrue(navigation.dismissCalled)
    }

    // MARK: UIAdaptivePresentationControllerDelegate
    func testPresentationDelegateCallingDidDismissEnds() {
        addMangasCoordinator.presentationControllerDidDismiss(UIPresentationController(presentedViewController: UIViewController(), presenting: nil))
        XCTAssertTrue(delegate.cancelCalled)
    }

    // MARK: FileSourceViewControllerDelegate
    func testFileSourceDelegateCallingOpenWebServerConfiguresUploadServer() {
        addMangasCoordinator.openWebServer(FileSourceViewController(delegate: addMangasCoordinator))
        XCTAssertEqual(mockServer.allowedFileExtensions, ["cbz", "zip", "rar", "cbr"])
        XCTAssert(mockServer.delegate is AddMangasCoordinator)
        XCTAssertTrue(mockServer.startCalled)
    }
}

class ViewMangaCoordinatorTests: XCTestCase {
    var navigation: MockNavigationController!
    var delegate: MockViewMangaCoordinatorDelegate! // swiftlint:disable:this weak_delegate
    var viewMangaCoordinator: ViewMangaCoordinator!
    var ocr: MockOCR!
    var manga: Manga!

    override func setUp() {
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
    }
}
