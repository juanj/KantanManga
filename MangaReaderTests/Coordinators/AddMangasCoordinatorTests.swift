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
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator(navigable: mockNavigation)

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
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator(uploadServer: mockUploadServer)
        addMangasCoordinator.didSelectBack(WebServerViewController())
        XCTAssertTrue(mockUploadServer.stopCalled)
    }

    // MARK: AddMangaViewControllerDelegate
    func testAddMangaViewControllerDelegateDidSelectBack_dismissesViewcontroller() {
        let mockNavigation = FakeNavigation()
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator(navigable: mockNavigation)
        mockNavigation.presentedViewController = UIViewController()

        addMangasCoordinator.cancel(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))

        XCTAssertNil(mockNavigation.presentedViewController)
    }

    func testAddMangaViewControllerDelegateSave_withPreviouslySelectedPath_callsCreateMangaWith() {
        let mockCoreDataManager = FakeCoreDataManager()
        let addMangaCoordinator = TestsFactories.createAddMangasCoordinator(coreDataManager: mockCoreDataManager)
        addMangaCoordinator.webUploader(FakeUploadServer(), didUploadFileAtPath: "Test.cbz")

        addMangaCoordinator.save(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()), name: "Test")

        XCTAssertTrue(mockCoreDataManager.createMangaWithCalls.contains(where: { ($0["path"] as? String) == "Test.cbz" && ($0["name"] as? String) == "Test" }))
    }

    func testAddMangaViewControllerDelegateSelectManga_withEmptyNavigation_pushesFileSourceViewController() {
        let addMangaCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        let mockNavigation = FakeNavigation()
        addMangaCoordinator.presentableNavigable = mockNavigation

        addMangaCoordinator.selectManga(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.viewControllers.first as? FileSourceViewController)
    }

    func testAddMangaViewControllerDelegateSelectCollection_withEmptyNavigation_pushesSelectCollectionTableViewController() {
        let addMangaCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        let mockNavigation = FakeNavigation()
        addMangaCoordinator.presentableNavigable = mockNavigation

        addMangaCoordinator.selectCollection(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.viewControllers.first as? SelectCollectionTableViewController)
    }

    // MARK: UIAdaptivePresentationControllerDelegate
    func testUIAdaptivePresentationControllerDelegatePresentationControllerDidDismiss_whilePresented_callsCancelOnDelegate() {
        let mockDelegate = FakeAddMangasCoordinatorDelegate()
        let addMangaCoordinator = TestsFactories.createAddMangasCoordinator(delegate: mockDelegate)

        addMangaCoordinator.presentationControllerDidDismiss(UIPresentationController(presentedViewController: UIViewController(), presenting: nil))

        XCTAssertTrue(mockDelegate.cancelCalled)
    }

    // MARK: FileSourceViewControllerDelegate
    func testFileSourceViewControllerDelegateOpenWebServer_withStopedWebServer_startsWebServer() {
        let mockUploadServer = FakeUploadServer()
        let addMangaCoordinator = TestsFactories.createAddMangasCoordinator(uploadServer: mockUploadServer)

        addMangaCoordinator.openWebServer(FileSourceViewController(delegate: FakeFileSourceViewControllerDelegate()))

        XCTAssertTrue(mockUploadServer.startCalled)
    }

    func testFileSourceViewControllerDelegateOpenWebServer_withEmptyNavigation_pushesWebServerViewController() {
        let mockNavigation = FakeNavigation()
        let addMangaCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        addMangaCoordinator.presentableNavigable = mockNavigation

        addMangaCoordinator.openWebServer(FileSourceViewController(delegate: FakeFileSourceViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.viewControllers.last as? WebServerViewController)
    }

    func testFileSourceViewControllerDelegateOpenLocalFiles_withEmptyNavigation_presentsUIDocumentPickerViewController() {
        let mockNavigation = FakeNavigation()
        let addMangaCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        addMangaCoordinator.presentableNavigable = mockNavigation

        addMangaCoordinator.openLocalFiles(FileSourceViewController(delegate: FakeFileSourceViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.presentedViewController as? UIDocumentPickerViewController)
    }
}
