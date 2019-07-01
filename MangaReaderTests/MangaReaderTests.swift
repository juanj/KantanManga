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

        _ = CoreDataManager.sharedManager.insertManga(totalPages: 100, filePath: "test.cbz")

        XCTAssertEqual(appCoordinator.loadMangas().count, 1)

        CoreDataManager.sharedManager.flushData()
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
    }

    override func tearDown() {
        super.tearDown()
        coreDataManager.flushData()
    }

    func testInitCoreDataManager() {
        let instance = CoreDataManager.sharedManager
        XCTAssertNotNil(instance)
    }

    func testCoreDataStackInitialization() {
        let coreDataStack = CoreDataManager.sharedManager.persistentContainer
        XCTAssertNotNil(coreDataStack)
    }

    func testCreateManga() {
        let manga1 = coreDataManager.insertManga(totalPages: 100, filePath: "file.cbz")
        XCTAssertNotNil(manga1)

        let manga2 = coreDataManager.insertManga(totalPages: 120, filePath: "file2.cbz")
        XCTAssertNotNil(manga2)

        let manga3 = coreDataManager.insertManga(totalPages: 57, filePath: "file3.cbz", currentPage: 14, coverImage: Data())
        XCTAssertNotNil(manga3)
    }

    func testFetchAllManga() {
        _ = coreDataManager.insertManga(totalPages: 100, filePath: "file.cbz")
        _ = coreDataManager.insertManga(totalPages: 100, filePath: "file.cbz")
        _ = coreDataManager.insertManga(totalPages: 100, filePath: "file.cbz")
        let results = coreDataManager.fetchAllMangas()
        XCTAssertEqual(results?.count, 3)
    }

    func testRemoveManga() {
        _ = coreDataManager.insertManga(totalPages: 100, filePath: "file.cbz")
        let items = coreDataManager.fetchAllMangas()
        let manga = items![0]
        coreDataManager.delete(manga: manga)
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
    }

    func testUpdateManga() {
        let manga = coreDataManager.insertManga(totalPages: 100, filePath: "file.cbz")!
        let totalPages = Int16(999)
        let filePath = "NewPath.cbz"
        let currentpage = Int16(850)
        let coverImage = "Test".data(using: .utf8)!

        CoreDataManager.sharedManager.update(manga: manga, totalPages: totalPages, filePath: filePath, currentPage: currentpage, coverImage: coverImage)

        let itemsFetched = coreDataManager.fetchAllMangas()
        let mangaFetched = itemsFetched![0]
        XCTAssertEqual(totalPages, mangaFetched.totalPages)
        XCTAssertEqual(filePath, mangaFetched.filePath)
        XCTAssertEqual(currentpage, mangaFetched.currentPage)
        XCTAssertEqual(coverImage, mangaFetched.coverData)

    }

    func testFlushData() {
        coreDataManager.flushData()
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
    }

}
