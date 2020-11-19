//
//  AddMangasCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import XCTest
@testable import Kantan_Manga

class AddMangasCoordinatorTests: XCTestCase {
    func testStart_presentsNavigationViewController() {
        let mockNavigation = FakeNavigation()
        let addMangasCoordinator = AddMangasCoordinator(navigation: mockNavigation, sourceButton: UIBarButtonItem(), uploadServer: FakeUploadServer(), coreDataManager: FakeCoreDataManager(), delegate: FakeAddMangasCoordinatorDelegate())

        addMangasCoordinator.start()
        let topViewController = mockNavigation.presentedViewController

        XCTAssertTrue(topViewController is UINavigationController)
    }

    // MARK: GCDWebUploaderDelegate
    func testWebUploaderDidUploadFileAtPath_stopsServer() {
        let mockUploadServer = FakeUploadServer()
        let addMangasCoordinator =  TestsFactories.createAddMangasCoordinator(uploadServer: mockUploadServer)
        addMangasCoordinator.webUploader(mockUploadServer, didUploadFileAtPath: "")
        XCTAssertTrue(mockUploadServer.stopCalled)
    }

    func testWebUploaderDidDeleteItemAtPath_withMangaWithPath_deletesManga() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator(coreDataManager: mockCoreDataManager)
        mockCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "test.cbz")

        addMangasCoordinator.webUploader(FakeUploadServer(), didDeleteItemAtPath: "test.cbz")

        XCTAssertEqual(mockCoreDataManager.fetchAllMangas()?.count, 0)
    }

    // MARK: WebServerViewControllerDelegate
    func testWebServerDelegateDidSelectBack_stopsServer() {
        let mockUploadServer = FakeUploadServer()
        let addMangasCoordinator = AddMangasCoordinator(navigation: FakeNavigation(), sourceButton: UIBarButtonItem(), uploadServer: mockUploadServer, coreDataManager: FakeCoreDataManager(), delegate: FakeAddMangasCoordinatorDelegate())
        addMangasCoordinator.didSelectBack(WebServerViewController())
        XCTAssertTrue(mockUploadServer.stopCalled)
    }

    // MARK: AddMangaViewControllerDelegate
    func testAddMangaViewControllerDelegateDidSelectBack_dismissesViewcontroller() {
        let mockNavigation = FakeNavigation()
        let addMangasCoordinator = AddMangasCoordinator(navigation: mockNavigation, sourceButton: UIBarButtonItem(), uploadServer: FakeUploadServer(), coreDataManager: FakeCoreDataManager(), delegate: FakeAddMangasCoordinatorDelegate())
        mockNavigation.presentedViewController = UIViewController()

        addMangasCoordinator.cancel(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))

        XCTAssertNil(mockNavigation.presentedViewController)
    }
}
