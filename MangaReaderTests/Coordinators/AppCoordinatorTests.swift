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

    func createAppCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager()) -> AppCoordinator {
        let appCoordinator = AppCoordinator(navigation: navigable, coreDataManager: coreDataManager)
        return appCoordinator
    }

    func createAddMangasCoordinator() -> AddMangasCoordinator {
        let addMangasCoordinator = AddMangasCoordinator(navigation: FakeNavigation(), sourceButton: UIBarButtonItem(), uploadServer: FakeUploadServer(), coreDataManager: InMemoryCoreDataManager(), delegate: FakeAddMangasCoordinatorDelegate())
        return addMangasCoordinator
    }

    func testStart_withEmptyNavigation_pushesLibraryViewController() {
        let mockNavigation = FakeNavigation()
        let appCoordinator = createAppCoordinator(navigable: mockNavigation)
        appCoordinator.start()

        let topViewController = mockNavigation.viewControllers.first

        XCTAssertTrue(topViewController is LibraryViewController)
    }

    func testLoadCollections_noCollections_returnsEmptyArray() {
        let appCoordinator = createAppCoordinator()

        let collections = appCoordinator.loadCollections()

        XCTAssertEqual(collections.count, 0)
    }

    func testLoadCollections_oneMangaWithoutCollection_returnsNoCollectionCollection() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(coreDataManager: stubCoreDataManager)
        stubCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")

        let collections = appCoordinator.loadCollections()

        XCTAssertTrue(collections.first!.name!.contains("No Collection"))
    }

    // MARK: LibraryViewControllerDelegate
    func testLibraryViewControllerDelegateDidSelectAdd_startsAddMangasCoordinator() {
        let appCoordinator = createAppCoordinator()
        let libraryViewController = FakeLibraryViewController()

        appCoordinator.didSelectAdd(libraryViewController, button: UIBarButtonItem())

        XCTAssertNotNil(appCoordinator.childCoordinators.first as? AddMangasCoordinator)
    }

    func testLibraryViewControllerDelegateDidSelectSettings_startsSettingsCoordinator() {
        let appCoordinator = createAppCoordinator()
        let libraryViewController = FakeLibraryViewController()

        appCoordinator.didSelectSettings(libraryViewController)

        XCTAssertNotNil(appCoordinator.childCoordinators.first as? SettingsCoordinator)
    }

    func testLibraryViewControllerDelegateDidSelectCollection_withOneCollection_pushesCollectionViewController() {
        let mockNavigation = FakeNavigation()
        let stubCoreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(navigable: mockNavigation, coreDataManager: stubCoreDataManager)
        let collection = stubCoreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])

        appCoordinator.didSelectCollection(libraryViewController, collection: collection, rotations: [])

        XCTAssertNotNil(mockNavigation.viewControllers.last as? CollectionViewController)
    }

    // MARK: AddMangasCoordinatorDelegate
    func testAddMangasCoordinatorDelegateDidEnd_removesCoordinator() {
        let appCoordinator = createAppCoordinator()
        let addMangasCoordinator = createAddMangasCoordinator()
        appCoordinator.childCoordinators.append(addMangasCoordinator)

        appCoordinator.didEnd(addMangasCoordinator)

        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }

    func testAddMangasCoordinatorDelegateCancel_removesCoordinator() {
        let appCoordinator = createAppCoordinator()
        let addMangasCoordinator = createAddMangasCoordinator()
        appCoordinator.childCoordinators.append(addMangasCoordinator)

        appCoordinator.cancel(addMangasCoordinator)

        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }
}
