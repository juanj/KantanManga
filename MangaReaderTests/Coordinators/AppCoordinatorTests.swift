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

    func createViewMangaCoordinator() -> ViewMangaCoordinator {
        let inMemoryCoreDataManager = InMemoryCoreDataManager()
        let manga = inMemoryCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: FakeNavigation(), coreDataManager: inMemoryCoreDataManager, manga: manga, delegate: FakeViewMangaCoordinatorDelegate(), originFrame: .zero, ocr: FakeImageOcr())

        return viewMangaCoordinator
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

    func testLibraryViewControllerDelegateDidSelectDeleteCollection_withOneCollection_deletesTheCollection() {
        let coreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(coreDataManager: coreDataManager)
        let collection = coreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])

        appCoordinator.didSelectDeleteCollection(libraryViewController, collection: collection)

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testLibraryViewControllerDelegateDidSelectRenameCollection_withOneCollectionNamedTest_renamesCollectionToDemo() {
        let coreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(coreDataManager: coreDataManager)
        let collection = coreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])

        appCoordinator.didSelectRenameCollection(libraryViewController, collection: collection, name: "Demo")

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.first?.name, "Demo")
    }

    // MARK: CollectionViewControllerDelegate
    func testCollectionViewControllerDelegateDidSelectManga_withOneManga_startsViewMangaCoordinator() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(coreDataManager: stubCoreDataManager)
        let manga = stubCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: [])

        appCoordinator.didSelectManga(collectionViewController, manga: manga, cellFrame: .zero)

        XCTAssertNotNil(appCoordinator.childCoordinators.last as? ViewMangaCoordinator)
    }

    func testCollectionViewControllerDelegateDidSelectDeleteManga_withOneManga_removesManga() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(coreDataManager: mockCoreDataManager)
        let manga = mockCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: [])

        appCoordinator.didSelectDeleteManga(collectionViewController, manga: manga)

        XCTAssertEqual(mockCoreDataManager.fetchAllMangas()?.count, 0)
    }

    func testCollectionViewControllerDelegateDidSelectRenameManga_withMangaNamedTestManga_renamesMangaToDemoManga() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(coreDataManager: mockCoreDataManager)
        let manga = mockCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: [])

        appCoordinator.didSelectRenameManga(collectionViewController, manga: manga, name: "Demo Manga")

        XCTAssertEqual(mockCoreDataManager.fetchAllMangas()?.first?.name, "Demo Manga")
    }

    func testCollectionViewControllerDelegateDidSelectMoveManga_withMangaWithoutCollection_presentsSelectCollectionTableViewController() {
        let mockNavigation = FakeNavigation()
        let stubCoreDataManager = InMemoryCoreDataManager()
        let appCoordinator = createAppCoordinator(navigable: mockNavigation, coreDataManager: stubCoreDataManager)
        let manga = stubCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: [])

        appCoordinator.didSelectMoveManga(collectionViewController, manga: manga)

        XCTAssertNotNil(mockNavigation.presentedViewController as? SelectCollectionTableViewController)
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

    // MARK: ViewMangaCoordinatorDelegate
    func testViewMangaCoordinatorDelegateDidEnd_withActiveViewMangaCoordinatorDelegate_removesCoordinator() {
        let appCoordinator = createAppCoordinator()
        let viewMangaCoordinator = createViewMangaCoordinator()
        appCoordinator.childCoordinators.append(viewMangaCoordinator)

        appCoordinator.didEnd(viewMangaCoordinator)

        XCTAssertEqual(appCoordinator.childCoordinators.count, 0)
    }
}
