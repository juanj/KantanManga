//
//  AddMangasCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import XCTest
@testable import Kantan_Manga

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
