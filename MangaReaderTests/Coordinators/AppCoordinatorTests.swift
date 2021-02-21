//
//  LibraryCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import XCTest
@testable import Kantan_Manga

class LibraryCoordinatorTests: XCTestCase {
    var navigation: Navigable!
    var libraryCoordinator: LibraryCoordinator!

    func testStart_withEmptyNavigation_pushesLibraryViewController() {
        let mockNavigation = FakeNavigation()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(navigable: mockNavigation)
        libraryCoordinator.start()

        let topViewController = mockNavigation.viewControllers.first

        XCTAssertTrue(topViewController is LibraryViewController)
    }

    func testLoadCollections_noCollections_returnsEmptyArray() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()

        let collections = libraryCoordinator.loadCollections()

        XCTAssertEqual(collections.count, 0)
    }

    func testLoadCollections_oneMangaWithoutCollection_returnsNoCollectionCollection() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: stubCoreDataManager)
        stubCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")

        let collections = libraryCoordinator.loadCollections()

        XCTAssertTrue(collections.first!.name!.contains("No Collection"))
    }

    // MARK: LibraryViewControllerDelegate
    func testLibraryViewControllerDelegateDidSelectAdd_startsAddMangasCoordinator() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()
        let libraryViewController = FakeLibraryViewController()

        libraryCoordinator.didSelectAdd(libraryViewController, button: UIBarButtonItem())

        XCTAssertNotNil(libraryCoordinator.childCoordinators.first as? AddMangasCoordinator)
    }

    func testLibraryViewControllerDelegateDidSelectSettings_startsSettingsCoordinator() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()
        let libraryViewController = FakeLibraryViewController()

        libraryCoordinator.didSelectSettings(libraryViewController)

        XCTAssertNotNil(libraryCoordinator.childCoordinators.first as? SettingsCoordinator)
    }

    func testLibraryViewControllerDelegateDidSelectCollection_withOneCollection_pushesCollectionViewController() {
        let mockNavigation = FakeNavigation()
        let stubCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(navigable: mockNavigation, coreDataManager: stubCoreDataManager)
        let collection = stubCoreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])

        libraryCoordinator.didSelectCollection(libraryViewController, collection: collection, rotations: [])

        XCTAssertNotNil(mockNavigation.viewControllers.last as? CollectionViewController)
    }

    func testLibraryViewControllerDelegateDidSelectDeleteCollection_withOneCollection_deletesTheCollection() {
        let coreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: coreDataManager)
        let collection = coreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])

        libraryCoordinator.didSelectDeleteCollection(libraryViewController, collection: collection)

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testLibraryViewControllerDelegateDidSelectRenameCollection_withOneCollectionNamedTest_renamesCollectionToDemo() {
        let coreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: coreDataManager)
        let collection = coreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])

        libraryCoordinator.didSelectRenameCollection(libraryViewController, collection: collection, name: "Demo")

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.first?.name, "Demo")
    }

    // MARK: CollectionViewControllerDelegate
    func testCollectionViewControllerDelegateDidSelectManga_withOneManga_startsViewMangaCoordinator() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: stubCoreDataManager)
        let manga = stubCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = TestsFactories.createCollectionViewController()

        libraryCoordinator.didSelectManga(collectionViewController, manga: manga, cellFrame: .zero)

        XCTAssertNotNil(libraryCoordinator.childCoordinators.last as? ViewMangaCoordinator)
    }

    func testCollectionViewControllerDelegateDidSelectDeleteManga_withOneManga_removesManga() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: mockCoreDataManager)
        let manga = mockCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = TestsFactories.createCollectionViewController()

        libraryCoordinator.didSelectDeleteManga(collectionViewController, manga: manga)

        XCTAssertEqual(mockCoreDataManager.fetchAllMangas()?.count, 0)
    }

    func testCollectionViewControllerDelegateDidSelectRenameManga_withMangaNamedTestManga_renamesMangaToDemoManga() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: mockCoreDataManager)
        let manga = mockCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = TestsFactories.createCollectionViewController()

        libraryCoordinator.didSelectRenameManga(collectionViewController, manga: manga, name: "Demo Manga")

        XCTAssertEqual(mockCoreDataManager.fetchAllMangas()?.first?.name, "Demo Manga")
    }

    func testCollectionViewControllerDelegateDidSelectMoveManga_withMangaWithoutCollection_presentsSelectCollectionTableViewController() {
        let mockNavigation = FakeNavigation()
        let stubCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(navigable: mockNavigation, coreDataManager: stubCoreDataManager)
        let manga = stubCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = TestsFactories.createCollectionViewController()

        libraryCoordinator.didSelectMoveManga(collectionViewController, manga: manga)

        XCTAssertNotNil(mockNavigation.presentedViewController as? SelectCollectionTableViewController)
    }

    // MARK: AddMangasCoordinatorDelegate
    func testAddMangasCoordinatorDelegateDidEnd_removesCoordinator() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator()
        libraryCoordinator.childCoordinators.append(addMangasCoordinator)

        libraryCoordinator.didEnd(addMangasCoordinator)

        XCTAssertEqual(libraryCoordinator.childCoordinators.count, 0)
    }

    func testAddMangasCoordinatorDelegateCancel_removesCoordinator() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()
        let addMangasCoordinator = TestsFactories.createAddMangasCoordinator()
        libraryCoordinator.childCoordinators.append(addMangasCoordinator)

        libraryCoordinator.cancel(addMangasCoordinator)

        XCTAssertEqual(libraryCoordinator.childCoordinators.count, 0)
    }

    // MARK: ViewMangaCoordinatorDelegate
    func testViewMangaCoordinatorDelegateDidEnd_withActiveViewMangaCoordinatorDelegate_removesCoordinator() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator()
        libraryCoordinator.childCoordinators.append(viewMangaCoordinator)

        libraryCoordinator.didEnd(viewMangaCoordinator)

        XCTAssertEqual(libraryCoordinator.childCoordinators.count, 0)
    }

    // MARK: SelectCollectionTableViewControllerDelegate
    func testSelectCollectionTableViewControllerDelegateSelectCollection_withPreviouslySelectedManga_changesMangaCollection() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: mockCoreDataManager)
        let manga = mockCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = TestsFactories.createCollectionViewController()
        libraryCoordinator.didSelectMoveManga(collectionViewController, manga: manga)
        let collection = mockCoreDataManager.insertCollection(name: "Test")!

        libraryCoordinator.selectCollection(SelectCollectionTableViewController(delegate: FakeSelectCollectionTableViewControllerDelegate(), collections: [collection]), collection: collection)

        XCTAssertEqual(mockCoreDataManager.fetchAllCollections()?.first?.mangas, [manga])
    }

    func testSelectCollectionTableViewControllerDelegateAddCollection_withPreviouslySelectedManga_createsCollection() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let libraryCoordinator = TestsFactories.createLibraryCoordinator(coreDataManager: mockCoreDataManager)
        let manga = mockCoreDataManager.insertManga(name: "Test Manga", coverData: Data(), totalPages: 0, filePath: "")!
        let collectionViewController = TestsFactories.createCollectionViewController()
        libraryCoordinator.didSelectMoveManga(collectionViewController, manga: manga)

        libraryCoordinator.addCollection(SelectCollectionTableViewController(delegate: FakeSelectCollectionTableViewControllerDelegate(), collections: []), name: "Test Collection")

        XCTAssertEqual(mockCoreDataManager.fetchAllCollections()?.first?.name, "Test Collection")
    }

    // MARK: UINavigationControllerDelegate
    func testUINavigationControllerDelegateAnimationControllerFor_formLibraryViewControllerToCollectionViewController_returnsOpenCollectionAnimationController() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()

        // Needed for setting indexPath
        let stubCoreDataManager = InMemoryCoreDataManager()
        let collection = stubCoreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])
        libraryCoordinator.didSelectCollection(libraryViewController, collection: collection, rotations: [])

        let animationController = libraryCoordinator.navigationController(UINavigationController(), animationControllerFor: .push,
                                                                      from: FakeLibraryViewController(),
                                                                      to: FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: []))

        XCTAssertNotNil(animationController as? OpenCollectionAnimationController)
    }

    func testUINavigationControllerDelegateAnimationControllerFor_formCollectionViewControllerToLibraryViewController_returnsOpenCollectionAnimationController() {
        let libraryCoordinator = TestsFactories.createLibraryCoordinator()

        // Needed for setting indexPath
        let stubCoreDataManager = InMemoryCoreDataManager()
        let collection = stubCoreDataManager.insertCollection(name: "Test")!
        let libraryViewController = FakeLibraryViewController(collections: [collection])
        libraryCoordinator.didSelectCollection(libraryViewController, collection: collection, rotations: [])

        let animationController = libraryCoordinator.navigationController(UINavigationController(), animationControllerFor: .push,
                                                                      from: FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: []),
                                                                      to: FakeLibraryViewController())

        XCTAssertNotNil(animationController as? OpenCollectionAnimationController)
    }

    
}
