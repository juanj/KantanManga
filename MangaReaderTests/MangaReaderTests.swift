//
//  MangaReaderTests.swift
//  MangaReaderTests
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import XCTest
import CoreData
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
}

class LibraryViewControllerTests: XCTestCase {
    func testCollectionViewDelegateAndDataSourceAreSetToViewController() {
        let libraryViewController = LibraryViewController()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        libraryViewController.collectionView = collectionView
        libraryViewController.configureCollectionView()

        XCTAssertEqual(libraryViewController.collectionView.delegate as? LibraryViewController, libraryViewController)
        XCTAssertEqual(libraryViewController.collectionView.dataSource as? LibraryViewController, libraryViewController)
    }
}

class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.sharedManager
        coreDataManager.deleteAllData()
    }

    override func tearDown() {
        super.tearDown()
        coreDataManager.deleteAllData()
    }

    /*
     TODO: Test theses methods
     createMangaWith
     */
    func testInitCoreDataManagerIsNotNil() {
        XCTAssertNotNil(coreDataManager)
    }

    func testContainerIsNotNil() {
        XCTAssertNotNil(coreDataManager.persistentContainer)
    }

    func testContextIsSavedCorrectly() {
        _ = Manga(context: coreDataManager.persistentContainer.viewContext, name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.persistentContainer.viewContext.reset()
        // Before save
        XCTAssertEqual(coreDataManager.fetchAllMangas(), [])

        _ = Manga(context: coreDataManager.persistentContainer.viewContext, name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.saveContext()
        coreDataManager.persistentContainer.viewContext.reset()
        // After Save
        XCTAssertNotNil(coreDataManager.fetchAllMangas())
    }

    func testAllDataIsDeleted() {
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")

        coreDataManager.insertCollection(name: "")
        coreDataManager.insertCollection(name: "")
        coreDataManager.insertCollection(name: "")
        coreDataManager.insertCollection(name: "")

        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 3)
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 4)

        coreDataManager.deleteAllData()

        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testMangaIsInserted() {
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        let manga = coreDataManager.fetchAllMangas()?.first
        XCTAssertNotNil(manga)
        // Test saved data
        XCTAssertEqual(manga?.coverData, Data())
        XCTAssertEqual(manga?.totalPages, 0)
        XCTAssertEqual(manga?.filePath, "")

        // Test generated data
        XCTAssertNotNil(manga?.createdAt)
        XCTAssertNotNil(manga?.currentPage)
        XCTAssertNil(manga?.lastViewedAt)

        coreDataManager.deleteAllData()

        coreDataManager.insertManga(name: "TestManga", coverData: "ABC".data(using: .utf8)!, totalPages: 5, filePath: "abc.cbz")
        let newManga = coreDataManager.fetchAllMangas()?.first
        XCTAssertNotNil(newManga)
        // Test saved data
        XCTAssertEqual(newManga?.name, "TestManga")
        XCTAssertEqual(newManga?.coverData, "ABC".data(using: .utf8)!)
        XCTAssertEqual(newManga?.totalPages, 5)
        XCTAssertEqual(newManga?.filePath, "abc.cbz")

        // Test generated data
        XCTAssertNotNil(newManga?.createdAt)
        XCTAssertNotNil(newManga?.currentPage)
        XCTAssertNil(newManga?.lastViewedAt)

        coreDataManager.deleteAllData()

        coreDataManager.insertManga(name: "TestManga2", coverData: "XYz".data(using: .utf8)!, totalPages: 1203, filePath: "abc-xyz.zip")
        let complexManga = coreDataManager.fetchAllMangas()?.first
        XCTAssertNotNil(complexManga)
        // Test saved data
        XCTAssertEqual(complexManga?.name, "TestManga2")
        XCTAssertEqual(complexManga?.coverData, "XYz".data(using: .utf8)!)
        XCTAssertEqual(complexManga?.totalPages, 1203)
        XCTAssertEqual(complexManga?.filePath, "abc-xyz.zip")

        // Test generated data
        XCTAssertNotNil(complexManga?.createdAt)
        XCTAssertNotNil(complexManga?.currentPage)
        XCTAssertNil(complexManga?.lastViewedAt)
    }

    func testMangaIsDeleted() {
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        XCTAssertNotNil(manga)
        XCTAssertNotNil(coreDataManager.fetchAllMangas()?.first)

        coreDataManager.delete(manga: manga!)
        XCTAssertNil(coreDataManager.fetchAllMangas()?.first)
    }

    func testAllMangasAreDeleted() {
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 3)

        coreDataManager.deleteAllMangas()
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
    }

    func testAllMangasAreFetched() {
        let manga1 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 5, filePath: "")
        let manga2 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 10, filePath: "bc")
        let manga3 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "de")

        XCTAssertEqual(coreDataManager.fetchAllMangas(), [manga1!, manga2!, manga3!])
    }

    func testMangaIsFetchedByFileName() {
        let manga1 = coreDataManager.insertManga(name: "Test A", coverData: Data(), totalPages: 10, filePath: "bc")
        let manga2 = coreDataManager.insertManga(name: "Test B", coverData: Data(), totalPages: 20, filePath: "de")

        XCTAssertEqual(coreDataManager.getMangaWith(filePath: "bc"), manga1)
        XCTAssertEqual(coreDataManager.getMangaWith(filePath: "de"), manga2)
    }

    func testMangaIsUpdated() {
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "")!

        XCTAssertEqual(manga.coverData, Data())
        XCTAssertEqual(manga.totalPages, 20)
        XCTAssertEqual(manga.currentPage, 0)
        XCTAssertEqual(manga.filePath, "")
        XCTAssertNil(manga.lastViewedAt)

        manga.currentPage = 5
        manga.filePath = "abc.cbz"
        coreDataManager.updateManga(manga: manga)

        let updatedManga = coreDataManager.fetchAllMangas()!.first!

        XCTAssertEqual(manga.coverData, Data())
        XCTAssertEqual(manga.totalPages, 20)
        XCTAssertEqual(manga.currentPage, 5)
        XCTAssertEqual(manga.filePath, "abc.cbz")
        XCTAssertNotNil(updatedManga.lastViewedAt)
        XCTAssertEqual(updatedManga.createdAt, manga.createdAt)
    }

    func testCollectionIsInserted() {
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
        coreDataManager.insertCollection(name: "")
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 1)
        coreDataManager.insertCollection(name: "")
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 2)
    }

    func testCollectionIsDeleted() {
        let collection = coreDataManager.insertCollection(name: "Test")!
        coreDataManager.insertCollection(name: "AAA")

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 2)
        coreDataManager.delete(collection: collection)
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 1)
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.first?.name, "AAA")
    }

    func testAllCollectionsAreDeleted() {
        coreDataManager.insertCollection(name: "1")
        coreDataManager.insertCollection(name: "2")
        coreDataManager.insertCollection(name: "3")
        coreDataManager.insertCollection(name: "4")
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 4)

        coreDataManager.deleteAllCollections()
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testAllCollectionsAreFetched() {
        let collection1 = coreDataManager.insertCollection(name: "1")!
        let collection2 = coreDataManager.insertCollection(name: "2")!
        let collection3 = coreDataManager.insertCollection(name: "3")!
        let collection4 = coreDataManager.insertCollection(name: "4")!
        XCTAssertEqual(coreDataManager.fetchAllCollections(), [collection1, collection2, collection3, collection4])
    }

    func testCollectionIsFoundByPartOfName() {
        let collection = coreDataManager.insertCollection(name: "This is a collection. No Cats")!
        let catsCollection = coreDataManager.insertCollection(name: "Cats. Lots of cats")!
        let dogCollection = coreDataManager.insertCollection(name: "Dogs, lots of dogs")!

        XCTAssertEqual(coreDataManager.searchCollectionsWith(name: "cat")?.count, 2)
        XCTAssertEqual(coreDataManager.searchCollectionsWith(name: "CaT"), [collection, catsCollection])
        XCTAssertEqual(coreDataManager.searchCollectionsWith(name: "DOGS")?.count, 1)
        XCTAssertEqual(coreDataManager.searchCollectionsWith(name: "DOGS")?.first, dogCollection)

    }

    func testMangaIsAddedToCollection() {
        let collection = coreDataManager.insertCollection(name: "A")
        let manga = coreDataManager.insertManga(name: "Test manga", coverData: Data(), totalPages: Int16(1), filePath: "file.cbz", collection: collection)!
        XCTAssertEqual(manga.mangaCollection, collection)
    }

    func testGetMangasByCollection() {
        let collection = coreDataManager.insertCollection(name: "A")
        let manga1 = coreDataManager.insertManga(name: "Test manga", coverData: Data(), totalPages: Int16(1), filePath: "file.cbz", collection: collection)!
        let manga2 = coreDataManager.insertManga(name: "New manga", coverData: Data(), totalPages: Int16(1), filePath: "file.cbz", collection: collection)!

        let aCollection = coreDataManager.searchCollectionsWith(name: "A")!.first!
        XCTAssertEqual(aCollection.mangas, [manga1, manga2])
    }
}
