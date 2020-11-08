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

    func testStart_withEmptyNavigation_pushesLibraryViewController() {
        let mockNavigation = FakeNavigation()
        let appCoordinator = AppCoordinator(navigation: mockNavigation, coreDataManager: FakeCoreDataManager())
        appCoordinator.start()

        let topViewController = mockNavigation.viewControllers.first

        XCTAssertTrue(topViewController is LibraryViewController)
    }

    func testLoadCollections_noCollections_returnsEmptyArray() {
        let stubNavigation = FakeNavigation()
        let appCoordinator = AppCoordinator(navigation: stubNavigation, coreDataManager: FakeCoreDataManager())

        let collections = appCoordinator.loadCollections()

        XCTAssertEqual(collections.count, 0)
    }

    func testLoadCollections_oneMangaWithoutCollection_returnsNoCollectionCollection() {
        let stubNavigation = FakeNavigation()
        let stubCoreDataManager = FakeCoreDataManager()
        stubCoreDataManager.mangas = [Manga()]
        let appCoordinator = AppCoordinator(navigation: stubNavigation, coreDataManager: stubCoreDataManager)

        let collections = appCoordinator.loadCollections()

        XCTAssertTrue(collections.first!.name!.contains("No Collection"))
    }

    // MARK: LibraryViewControllerDelegate
    func testLibraryViewControllerDelegateDidSelectAdd_startsAddMangasCoordinator() {
        let stubNavigation = FakeNavigation()
        let appCoordinator = AppCoordinator(navigation: stubNavigation, coreDataManager: FakeCoreDataManager())
        let libraryViewController = FakeLibraryViewController()

        appCoordinator.didSelectAdd(libraryViewController, button: UIBarButtonItem())

        XCTAssertNotNil(appCoordinator.childCoordinators.first as? AddMangasCoordinator)
    }

    func testLibraryViewControllerDelegateDidSelectSettings_startsSettingsCoordinator() {
        let stubNavigation = FakeNavigation()
        let appCoordinator = AppCoordinator(navigation: stubNavigation, coreDataManager: FakeCoreDataManager())
        let libraryViewController = FakeLibraryViewController()

        appCoordinator.didSelectSettings(libraryViewController)

        XCTAssertNotNil(appCoordinator.childCoordinators.first as? SettingsCoordinator)
    }

    // MARK: AddMangasCoordinatorDelegate
    func testAddMangasCoordinatorDelegateDidEnd_removesCoordinator() {
        let stubNavigation = FakeNavigation()
        let appCoordinator = AppCoordinator(navigation: stubNavigation, coreDataManager: FakeCoreDataManager())
        let addMangasCoordinator = AddMangasCoordinator(navigation: stubNavigation, sourceButton: UIBarButtonItem(), uploadServer: FakeUploadServer(), coreDataManager: FakeCoreDataManager(), delegate: appCoordinator)
        appCoordinator.childCoordinators.append(addMangasCoordinator)

        appCoordinator.didEnd(addMangasCoordinator)

        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }

    func testAddMangasCoordinatorDelegateCancel_removesCoordinator() {
        let stubNavigation = FakeNavigation()
        let appCoordinator = AppCoordinator(navigation: stubNavigation, coreDataManager: FakeCoreDataManager())
        let addMangasCoordinator = AddMangasCoordinator(navigation: stubNavigation, sourceButton: UIBarButtonItem(), uploadServer: FakeUploadServer(), coreDataManager: FakeCoreDataManager(), delegate: appCoordinator)
        appCoordinator.childCoordinators.append(addMangasCoordinator)

        appCoordinator.cancel(addMangasCoordinator)

        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }
}
