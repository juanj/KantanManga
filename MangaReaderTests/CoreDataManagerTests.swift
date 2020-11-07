//
//  MangaReaderTests.swift
//  MangaReaderTests
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import XCTest
import CoreData
@testable import Kantan_Manga

class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!

    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager()
        coreDataManager.deleteAllData()
    }

    override func tearDown() {
        super.tearDown()
        coreDataManager.deleteAllData()
    }

    func testDeleteAllData_afterInsertingData_deletesAllData() {
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertCollection(name: "")
        coreDataManager.insertCollection(name: "")
        coreDataManager.insertCollection(name: "")
        coreDataManager.insertCollection(name: "")

        coreDataManager.deleteAllData()

        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testInsertManga_mangaIsInserted() {
        let manga1 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        let manga2 = coreDataManager.fetchAllMangas()?.first
        XCTAssertEqual(manga1, manga2)
    }

    func testInsertManga_afterInserting_defaultFieldsArePopulated() {
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")

        XCTAssertNotNil(manga?.createdAt)
        XCTAssertNotNil(manga?.currentPage)
        XCTAssertNil(manga?.lastViewedAt)
    }

    func testInsertManga_mangaIsAddedToCollection() {
        let collection = coreDataManager.insertCollection(name: "A")
        let manga = coreDataManager.insertManga(name: "Test manga", coverData: Data(), totalPages: Int16(1), filePath: "file.cbz", collection: collection)!
        XCTAssertEqual(manga.mangaCollection, collection)
    }

    func testDelete_mangaIsDeleted() {
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")

        coreDataManager.delete(manga: manga!)

        XCTAssertNil(coreDataManager.fetchAllMangas()?.first)
    }

    func testDeleteAllMangas_allMangasAreDeleted() {
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")

        coreDataManager.deleteAllMangas()
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
    }

    func testFetchAllMangas_allMangasAreFetched() {
        let manga1 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 5, filePath: "")
        let manga2 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 10, filePath: "bc")
        let manga3 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "de")

        XCTAssertEqual(coreDataManager.fetchAllMangas(), [manga1!, manga2!, manga3!])
    }

    func testGetMangaWith_mangaIsFetchedByFileName() {
        coreDataManager.insertManga(name: "Test A", coverData: Data(), totalPages: 10, filePath: "this_file.cbz")
        let manga = coreDataManager.insertManga(name: "Test B", coverData: Data(), totalPages: 20, filePath: "not_that_file.cbr")

        XCTAssertEqual(coreDataManager.getMangaWith(filePath: "not_that_file.cbr"), manga)
    }

    func testGetMangasWithoutCollection_multipleMangas_getsCorrectMangas() {
        let collection = coreDataManager.insertCollection(name: "Test Collection")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 5, filePath: "", collection: collection)
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 10, filePath: "bc")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "de", collection: collection)

        let mangasWithoutCollection = coreDataManager.getMangasWithoutCollection()

        XCTAssertEqual(mangasWithoutCollection, [manga!])
    }

    func testUpdateManga_afterUpdatingInfo_savesCorrectInfo() {
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "")!

        manga.currentPage = 5
        manga.filePath = "abc.cbz"
        coreDataManager.updateManga(manga: manga)

        let updatedManga = coreDataManager.fetchAllMangas()!.first!

        XCTAssertEqual(updatedManga.currentPage, 5)
        XCTAssertEqual(updatedManga.filePath, "abc.cbz")
    }

    func testUpdateManga_updatesLastViewedDate() {
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "")!

        manga.currentPage = 5
        coreDataManager.updateManga(manga: manga)

        XCTAssertNotNil(manga.lastViewedAt)
    }

    func testInsertCollection_collectionIsInserted() {
        coreDataManager.insertCollection(name: "")

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 1)
    }

    func testDeleteCollection_collectionIsDeleted() {
        let collection = coreDataManager.insertCollection(name: "Test")!
        coreDataManager.delete(collection: collection)
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testDeleteAllCollections_allCollectionsAreDeleted() {
        coreDataManager.insertCollection(name: "1")
        coreDataManager.insertCollection(name: "2")
        coreDataManager.insertCollection(name: "3")
        coreDataManager.insertCollection(name: "4")

        coreDataManager.deleteAllCollections()

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testFetchAllCollections_allCollectionsAreFetched() {
        let collection1 = coreDataManager.insertCollection(name: "1")!
        let collection2 = coreDataManager.insertCollection(name: "2")!
        let collection3 = coreDataManager.insertCollection(name: "3")!
        let collection4 = coreDataManager.insertCollection(name: "4")!

        XCTAssertEqual(coreDataManager.fetchAllCollections(), [collection1, collection2, collection3, collection4])
    }

    func testSearchCollectionsWith_collectionIsFoundByPartOfName() {
        let collection = coreDataManager.insertCollection(name: "This is a collection. No Cats")!
        let catsCollection = coreDataManager.insertCollection(name: "Cats. Lots of cats")!
        let dogCollection = coreDataManager.insertCollection(name: "Dogs, lots of dogs")!

        XCTAssertEqual(coreDataManager.searchCollectionsWith(name: "cat"), [collection, catsCollection])
    }

    func testSearchCollectionsWith_usingUpperCaseAndLowercase_isCaseInsensitive() {
        coreDataManager.insertCollection(name: "This is a collection. No Cats")
        coreDataManager.insertCollection(name: "Cats. Lots of cats")
        let dogCollection = coreDataManager.insertCollection(name: "Dogs, lots of dogs")!

        XCTAssertEqual(coreDataManager.searchCollectionsWith(name: "DoGs"), [dogCollection])
    }

    func testSearchCollectionsStartWith_usingFirstWord_ignoresCollectionIfDontStartWithWord() {
        coreDataManager.insertCollection(name: "This is a collection. No Cats")
        let catsCollection = coreDataManager.insertCollection(name: "Cats. I love them")!

        XCTAssertEqual(coreDataManager.searchCollectionsStartWith(name: "Cats"), [catsCollection])
    }

    func testUpdateCollection_afterChangingName_isUpdated() {
        let collection = coreDataManager.insertCollection(name: "Demo collection")!

        collection.name = "Test Collection"
        coreDataManager.updateCollection(collection)
        let testCollection = coreDataManager.fetchAllCollections()!.first!

        XCTAssertEqual(testCollection.name, "Test Collection")
    }

    func testCreateDemoManga_createsDemoManga() {
        let expectation = XCTestExpectation(description: "Demo manga is copied from bundle and is inserted")
        coreDataManager.createDemoManga {
            let manga = self.coreDataManager.getMangaWith(filePath: "demo1.cbz")
            XCTAssertNotNil(manga)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
