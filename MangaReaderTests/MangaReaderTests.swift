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
        
        let _ = CoreDataManager.sharedManager.insertManga(title: "Test", totalPages: 100, filePath: "test.cbz")
        
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
    
    func testInitCoreDataManager(){
        let instance = CoreDataManager.sharedManager
        XCTAssertNotNil(instance)
    }
    
    func testCoreDataStackInitialization() {
        let coreDataStack = CoreDataManager.sharedManager.persistentContainer
        XCTAssertNotNil(coreDataStack)
    }
    
    func testCreateManga() {
        let manga1 = coreDataManager.insertManga(title: "Manga 1", totalPages: 100, filePath: "file.cbz")
        XCTAssertNotNil(manga1)
        
        let manga2 = coreDataManager.insertManga(title: "Manga 2", totalPages: 120, filePath: "file2.cbz")
        XCTAssertNotNil(manga2)
        
        let manga3 = coreDataManager.insertManga(title: "Manga 3", totalPages: 57, filePath: "file3.cbz", currentPage: 14, coverImage: Data())
        XCTAssertNotNil(manga3)
    }
    
    func testFetchAllManga() {
        let results = coreDataManager.fetchAllMangas()
        XCTAssertEqual(results?.count, 3)
    }
    
    func testRemoveManga() {
        let _ = coreDataManager.insertManga(title: "Manga 1", totalPages: 100, filePath: "file.cbz")
        let items = coreDataManager.fetchAllMangas()
        let manga = items![0]
        let numberOfItems = items?.count
        coreDataManager.delete(manga: manga)
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, numberOfItems!-1)
    }
    
    func testUpdateManga(){
        let items = coreDataManager.fetchAllMangas()
        let manga = items![0]
        let title = "New Manga Name"
        let totalPages = Int16(999)
        let filePath = "NewPath.cbz"
        let currentpage = Int16(850)
        let coverImage = "Test".data(using: .utf8)!
        
        CoreDataManager.sharedManager.update(manga: manga, title: title, totalPages: totalPages, filePath: filePath, currentPage: currentpage, coverImage: coverImage)
        
        let itemsFetched = coreDataManager.fetchAllMangas()
        let mangaFetched = itemsFetched![0]
        XCTAssertEqual(title, mangaFetched.title)
        XCTAssertEqual(totalPages, mangaFetched.totalPages)
        XCTAssertEqual(filePath, mangaFetched.filePath)
        XCTAssertEqual(currentpage, mangaFetched.currentPage)
        XCTAssertEqual(coverImage, mangaFetched.coverImage)

    }
    
    func testFlushData() {
        coreDataManager.flushData()
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
    }
    
}
