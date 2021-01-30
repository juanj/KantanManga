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
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator(uploadServer: mockUploadServer)
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
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator(coreDataManager: mockCoreDataManager)
        addMangasCoordinator.webUploader(FakeUploadServer(), didUploadFileAtPath: "Test.cbz")

        addMangasCoordinator.save(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()), name: "Test")

        print(mockCoreDataManager.createMangaWithCalls)
        XCTAssertTrue(mockCoreDataManager.createMangaWithCalls.contains(where: { ($0["path"] as? String) == "Test.cbz" && ($0["name"] as? String) == "Test" }))
    }

    func testAddMangaViewControllerDelegateSelectManga_withEmptyNavigation_pushesFileSourceViewController() {
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        let mockNavigation = FakeNavigation()
        addMangasCoordinator.presentableNavigable = mockNavigation

        addMangasCoordinator.selectManga(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.viewControllers.first as? FileSourceViewController)
    }

    func testAddMangaViewControllerDelegateSelectCollection_withEmptyNavigation_pushesSelectCollectionTableViewController() {
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        let mockNavigation = FakeNavigation()
        addMangasCoordinator.presentableNavigable = mockNavigation

        addMangasCoordinator.selectCollection(AddMangaViewController(delegate: MockAddMangaViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.viewControllers.first as? SelectCollectionTableViewController)
    }

    // MARK: UIAdaptivePresentationControllerDelegate
    func testUIAdaptivePresentationControllerDelegatePresentationControllerDidDismiss_whilePresented_callsCancelOnDelegate() {
        let mockDelegate = FakeAddMangasCoordinatorDelegate()
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator(delegate: mockDelegate)

        addMangasCoordinator.presentationControllerDidDismiss(UIPresentationController(presentedViewController: UIViewController(), presenting: nil))

        XCTAssertTrue(mockDelegate.cancelCalled)
    }

    // MARK: FileSourceViewControllerDelegate
    func testFileSourceViewControllerDelegateOpenWebServer_withStopedWebServer_startsWebServer() {
        let mockUploadServer = FakeUploadServer()
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator(uploadServer: mockUploadServer)

        addMangasCoordinator.openWebServer(FileSourceViewController(delegate: FakeFileSourceViewControllerDelegate()))

        XCTAssertTrue(mockUploadServer.startCalled)
    }

    func testFileSourceViewControllerDelegateOpenWebServer_withEmptyNavigation_pushesWebServerViewController() {
        let mockNavigation = FakeNavigation()
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        addMangasCoordinator.presentableNavigable = mockNavigation

        addMangasCoordinator.openWebServer(FileSourceViewController(delegate: FakeFileSourceViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.viewControllers.last as? WebServerViewController)
    }

    func testFileSourceViewControllerDelegateOpenLocalFiles_withEmptyNavigation_presentsUIDocumentPickerViewController() {
        let mockNavigation = FakeNavigation()
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        addMangasCoordinator.presentableNavigable = mockNavigation

        addMangasCoordinator.openLocalFiles(FileSourceViewController(delegate: FakeFileSourceViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.presentedViewController as? UIDocumentPickerViewController)
    }

    // MARK: SelectCollectionTableViewControllerDelegate
    func testSelectCollection_withSelectCollectionTableViewControllerOnTheNavigationStack_popsViewController() {
        let mockNavigation = FakeNavigation()
        let stubCoreDataManager = InMemoryCoreDataManager()
        let collection = stubCoreDataManager.insertCollection(name: "Test")!
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        addMangasCoordinator.presentableNavigable = mockNavigation

        let selectCollectionView = SelectCollectionTableViewController(delegate: FakeSelectCollectionTableViewControllerDelegate(), collections: [collection])
        mockNavigation.pushViewController(selectCollectionView, animated: false)
        addMangasCoordinator.selectCollection(selectCollectionView, collection: collection)

        XCTAssertEqual(mockNavigation.viewControllers.count, 0)
    }

    func testAddCollection_withSelectCollectionTableViewControllerOnTheNavigationStack_popsViewController() {
        let mockNavigation = FakeNavigation()
        let addMangasCoordinator = TestsFactories.createTestableAddMangasCoordinator()
        addMangasCoordinator.presentableNavigable = mockNavigation

        let selectCollectionView = SelectCollectionTableViewController(delegate: FakeSelectCollectionTableViewControllerDelegate(), collections: [])
        mockNavigation.pushViewController(selectCollectionView, animated: false)
        addMangasCoordinator.addCollection(selectCollectionView, name: "Test")

        XCTAssertEqual(mockNavigation.viewControllers.count, 0)
    }

    func testAddCollection_with0createdCollections_createsCollection() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator(coreDataManager: mockCoreDataManager)

        let selectCollectionView = SelectCollectionTableViewController(delegate: FakeSelectCollectionTableViewControllerDelegate(), collections: [])
        addMangasCoordinator.addCollection(selectCollectionView, name: "Test")

        XCTAssertEqual(mockCoreDataManager.fetchAllCollections()?.count, 1)
    }
}
