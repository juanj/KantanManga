//
//  AppCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import XCTest
@testable import Kantan_Manga

class AppCoordinatorTests: XCTestCase {
    var navigation: Navigable!
    var appCoordinator: AppCoordinator!

    func testCallingStartPushLibraryViewController() {
        let navigation = MockNavigation()
        let appCoordinator = AppCoordinator(navigation: navigation, coreDataManager: FakeCoreDataManager())
        appCoordinator.start()
        XCTAssertTrue(navigation.viewControllers.first is LibraryViewController)
    }

    /*func testLoadCollectionsWithMangas() {
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
    }*/

}
