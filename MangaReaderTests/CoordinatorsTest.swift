//
//  CoordinatorsTest.swift
//  MangaReaderTests
//
//  Created by Juan on 29/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import XCTest
@testable import MangaReader

class AppCoordinatorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        CoreDataManager.sharedManager.deleteAllData()
    }

    func testCallingStartPushLibraryViewController() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)
        appCoordinator.start()

        XCTAssertTrue(navigation.viewControllers.first is LibraryViewController)
    }

    func testLoadMangas() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)

        XCTAssertNotNil(appCoordinator.loadMangas())

        CoreDataManager.sharedManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 100, filePath: "test.cbz")

        XCTAssertEqual(appCoordinator.loadMangas().count, 1)
    }

    // MARK: LibraryViewControllerDelegate
    func testLibraryDelegateDeleteMangaDeletesMangaFromDataBase() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)

        let manga = CoreDataManager.sharedManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 100, filePath: "test.cbz")!
        let delegate = DummyLibraryViewControllerDelegate()
        let libraryViewController = MockLibraryViewController(delegate: delegate)

        XCTAssertEqual(CoreDataManager.sharedManager.fetchAllMangas()?.count, 1)
        appCoordinator.didSelectDeleteManga(libraryViewController, manga: manga)
        XCTAssertEqual(CoreDataManager.sharedManager.fetchAllMangas()?.count, 0)
    }

    func testLibraryDelegateSelectMangaStartCoordinator() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)
        let manga = CoreDataManager.sharedManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 100, filePath: "test.cbz")!
        let delegate = DummyLibraryViewControllerDelegate()
        let libraryViewController = MockLibraryViewController(delegate: delegate)

        appCoordinator.didSelectManga(libraryViewController, manga: manga, cellFrame: .zero)

        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertNotNil(appCoordinator.childCoordinators.first as? ViewMangaCoordinator)
    }

    func testLibraryDelegateSelectAddStartCoordinator() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)
        let delegate = DummyLibraryViewControllerDelegate()
        let libraryViewController = MockLibraryViewController(delegate: delegate)

        appCoordinator.didSelectAdd(libraryViewController, button: UIBarButtonItem())

        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        XCTAssertNotNil(appCoordinator.childCoordinators.first as? AddMangasCoordinator)
    }

    // MARK: AddMangasCoordinatorDelegate
    func testAddMangaDelegateEndRemoveCoordinator() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: MockUploadServer(), delegate: appCoordinator)
        appCoordinator.childCoordinators.append(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        appCoordinator.didEnd(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }

    func testAddMangaDelegateCancelRemoveCoordinator() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: MockUploadServer(), delegate: appCoordinator)
        appCoordinator.childCoordinators.append(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
        appCoordinator.cancel(addMangasCoordinator)
        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }
}

class AddMangasCoordinatorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        CoreDataManager.sharedManager.deleteAllData()
    }

    func testCallingStarPresentsNavigationWithAddMangaViewController() {
        let navigation = MockNavigationController()
        let delegate = MockAddMangasCoordinatorDelegate()
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: MockUploadServer(), delegate: delegate)
        addMangasCoordinator.start()

        XCTAssertTrue((navigation.presentedViewControllerTest as? UINavigationController)?.viewControllers.first is AddMangaViewController)
    }

    // MARK: GCDWebUploaderDelegate
    func testUploaderDelegateCallingDidUploadStopsServer() {
        let navigation = MockNavigationController()
        let delegate = MockAddMangasCoordinatorDelegate()
        let mockServer = MockUploadServer()
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: mockServer, delegate: delegate)
        addMangasCoordinator.webUploader(mockServer, didUploadFileAtPath: "")

        XCTAssertTrue(mockServer.stopCalled)
    }

    func testUploaderDelegateCallingDidDeleteRemovesManga() {
        let navigation = MockNavigationController()
        let delegate = MockAddMangasCoordinatorDelegate()
        let mockServer = MockUploadServer()
        let manga = CoreDataManager.sharedManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 100, filePath: "test.cbz")!
        XCTAssertEqual(CoreDataManager.sharedManager.fetchAllMangas(), [manga])

        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: mockServer, delegate: delegate)
        addMangasCoordinator.webUploader(mockServer, didDeleteItemAtPath: "test.cbz")

        XCTAssertEqual(CoreDataManager.sharedManager.fetchAllMangas(), [])
    }

    // MARK: WebServerViewControllerDelegate
    func testWebServerDelegateCallingDidSelectBackStopsServer() {
        let navigation = MockNavigationController()
        let delegate = MockAddMangasCoordinatorDelegate()
        let mockServer = MockUploadServer()
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: mockServer, delegate: delegate)
        addMangasCoordinator.didSelectBack(WebServerViewController())

        XCTAssertTrue(mockServer.stopCalled)
    }

    // MARK: AddMangaViewControllerDelegate
    func testAddMangaDelegateCallingCancelDismissAndCancels() {
        let navigation = MockNavigationController()
        let delegate = MockAddMangasCoordinatorDelegate()
        let mockServer = MockUploadServer()
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: mockServer, delegate: delegate)
        addMangasCoordinator.cancel(addMangaViewController: AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))

        XCTAssertTrue(delegate.cancelCalled)
        XCTAssertTrue(navigation.dismissCalled)
    }

    func testFileSourceDelegateCallingOpenWebServerConfiguresUploadServer() {
        let navigation = MockNavigationController()
        let delegate = MockAddMangasCoordinatorDelegate()
        let mockServer = MockUploadServer()
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: UIBarButtonItem(), uploadServer: mockServer, delegate: delegate)
        addMangasCoordinator.openWebServer(fileSourceViewController: FileSourceViewController(delegate: addMangasCoordinator))

        XCTAssertEqual(mockServer.allowedFileExtensions, ["cbz", "zip", "rar", "cbr"])
        XCTAssert(mockServer.delegate is AddMangasCoordinator)
        XCTAssertTrue(mockServer.startCalled)
    }
}
