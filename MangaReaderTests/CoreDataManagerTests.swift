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
    func testDeleteAllData_afterInsertingData_deletesAllData() {
        let coreDataManager = InMemoryCoreDataManager()
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
        let coreDataManager = InMemoryCoreDataManager()
        let manga1 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        let manga2 = coreDataManager.fetchAllMangas()?.first
        XCTAssertEqual(manga1, manga2)
    }

    func testInsertManga_afterInserting_defaultFieldsArePopulated() {
        let coreDataManager = InMemoryCoreDataManager()
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")

        XCTAssertNotNil(manga?.createdAt)
        XCTAssertNotNil(manga?.currentPage)
        XCTAssertNil(manga?.lastViewedAt)
    }

    func testInsertManga_mangaIsAddedToCollection() {
        let coreDataManager = InMemoryCoreDataManager()
        let collection = coreDataManager.insertCollection(name: "A")
        let manga = coreDataManager.insertManga(name: "Test manga", coverData: Data(), totalPages: Int16(1), filePath: "file.cbz", collection: collection)!
        XCTAssertEqual(manga.mangaCollection, collection)
    }

    func testDeleteManga_mangaIsDeleted() {
        let coreDataManager = InMemoryCoreDataManager()
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")

        coreDataManager.delete(manga: manga!)

        XCTAssertNil(coreDataManager.fetchAllMangas()?.first)
    }

    func testDeleteAllMangas_allMangasAreDeleted() {
        let coreDataManager = InMemoryCoreDataManager()
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 0, filePath: "")

        coreDataManager.deleteAllMangas()
        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
    }

    func testFetchAllMangas_allMangasAreFetched() {
        let coreDataManager = InMemoryCoreDataManager()
        let manga1 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 5, filePath: "")
        let manga2 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 10, filePath: "bc")
        let manga3 = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "de")

        // Use set so order doesn't matter
        XCTAssertEqual(Set(coreDataManager.fetchAllMangas()!), Set([manga1!, manga2!, manga3!]))
    }

    func testGetMangaWith_mangaIsFetchedByFileName() {
        let coreDataManager = InMemoryCoreDataManager()
        coreDataManager.insertManga(name: "Test A", coverData: Data(), totalPages: 10, filePath: "this_file.cbz")
        let manga = coreDataManager.insertManga(name: "Test B", coverData: Data(), totalPages: 20, filePath: "not_that_file.cbr")

        XCTAssertEqual(coreDataManager.getMangaWith(filePath: "not_that_file.cbr"), manga)
    }

    func testGetMangasWithoutCollection_multipleMangas_getsCorrectMangas() {
        let coreDataManager = InMemoryCoreDataManager()
        let collection = coreDataManager.insertCollection(name: "Test Collection")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 5, filePath: "", collection: collection)
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 10, filePath: "bc")
        coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "de", collection: collection)

        let mangasWithoutCollection = coreDataManager.getMangasWithoutCollection()

        XCTAssertEqual(mangasWithoutCollection, [manga!])
    }

    func testUpdateManga_afterUpdatingInfo_savesCorrectInfo() {
        let coreDataManager = InMemoryCoreDataManager()
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "")!

        manga.currentPage = 5
        manga.filePath = "abc.cbz"
        coreDataManager.updateManga(manga: manga)

        let updatedManga = coreDataManager.fetchAllMangas()!.first!

        XCTAssertEqual(updatedManga.currentPage, 5)
        XCTAssertEqual(updatedManga.filePath, "abc.cbz")
    }

    func testUpdateManga_updatesLastViewedDate() {
        let coreDataManager = InMemoryCoreDataManager()
        let manga = coreDataManager.insertManga(name: "", coverData: Data(), totalPages: 20, filePath: "")!

        manga.currentPage = 5
        coreDataManager.updateManga(manga: manga)

        XCTAssertNotNil(manga.lastViewedAt)
    }

    func testInsertCollection_collectionIsInserted() {
        let coreDataManager = InMemoryCoreDataManager()
        coreDataManager.insertCollection(name: "")

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 1)
    }

    func testDeleteCollection_collectionIsDeleted() {
        let coreDataManager = InMemoryCoreDataManager()
        let collection = coreDataManager.insertCollection(name: "Test")!
        coreDataManager.delete(collection: collection)
        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testDeleteCollection_withAssociatedMangas_mangasAreDeleted() {
        let coreDataManager = InMemoryCoreDataManager()
        let collection = coreDataManager.insertCollection(name: "Test")!
        coreDataManager.insertManga(name: "Test1", coverData: Data(), totalPages: 0, filePath: "", collection: collection)
        coreDataManager.insertManga(name: "Test2", coverData: Data(), totalPages: 0, filePath: "", collection: collection)

        coreDataManager.delete(collection: collection)

        XCTAssertEqual(coreDataManager.fetchAllMangas()?.count, 0)
    }

    func testDeleteAllCollections_allCollectionsAreDeleted() {
        let coreDataManager = InMemoryCoreDataManager()
        coreDataManager.insertCollection(name: "1")
        coreDataManager.insertCollection(name: "2")
        coreDataManager.insertCollection(name: "3")
        coreDataManager.insertCollection(name: "4")

        coreDataManager.deleteAllCollections()

        XCTAssertEqual(coreDataManager.fetchAllCollections()?.count, 0)
    }

    func testFetchAllCollections_allCollectionsAreFetched() {
        let coreDataManager = InMemoryCoreDataManager()
        let collection1 = coreDataManager.insertCollection(name: "1")!
        let collection2 = coreDataManager.insertCollection(name: "2")!
        let collection3 = coreDataManager.insertCollection(name: "3")!
        let collection4 = coreDataManager.insertCollection(name: "4")!

        // Use set so order doesn't matter
        XCTAssertEqual(Set(coreDataManager.fetchAllCollections()!), Set([collection1, collection2, collection3, collection4]))
    }

    func testSearchCollectionsWith_collectionIsFoundByPartOfName() {
        let coreDataManager = InMemoryCoreDataManager()
        let collection = coreDataManager.insertCollection(name: "This is a collection. No Cats")!
        let catsCollection = coreDataManager.insertCollection(name: "Cats. Lots of cats")!
        coreDataManager.insertCollection(name: "Dogs, lots of dogs")

        // Use set so order doesn't matter
        XCTAssertEqual(Set(coreDataManager.searchCollectionsWith(name: "cat")!), Set([collection, catsCollection]))
    }

    func testSearchCollectionsWith_usingUpperCaseAndLowercase_isCaseInsensitive() {
        let coreDataManager = InMemoryCoreDataManager()
        coreDataManager.insertCollection(name: "This is a collection. No Cats")
        coreDataManager.insertCollection(name: "Cats. Lots of cats")
        let dogCollection = coreDataManager.insertCollection(name: "Dogs, lots of dogs")!

        XCTAssertEqual(coreDataManager.searchCollectionsWith(name: "DoGs"), [dogCollection])
    }

    func testSearchCollectionsStartWith_usingFirstWord_ignoresCollectionIfDontStartWithWord() {
        let coreDataManager = InMemoryCoreDataManager()
        coreDataManager.insertCollection(name: "This is a collection. No Cats")
        let catsCollection = coreDataManager.insertCollection(name: "Cats. I love them")!

        XCTAssertEqual(coreDataManager.searchCollectionsStartWith(name: "Cats"), [catsCollection])
    }

    func testUpdateCollection_afterChangingName_isUpdated() {
        let coreDataManager = InMemoryCoreDataManager()
        let collection = coreDataManager.insertCollection(name: "Demo collection")!

        collection.name = "Test Collection"
        coreDataManager.updateCollection(collection)
        let testCollection = coreDataManager.fetchAllCollections()!.first!

        XCTAssertEqual(testCollection.name, "Test Collection")
    }

    func testInsertSentence_withInMemoryCoreDataManager_insertsSentence() {
        let coreDataManager = InMemoryCoreDataManager()

        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)

        XCTAssertEqual(coreDataManager.fetchAllSentences()?.count, 1)
    }

    func testDeleteSentence_afterInsertingMultipleSentences_deletesSentence() {
        let coreDataManager = InMemoryCoreDataManager()

        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)
        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)
        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)
        let sentence = coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)!
        coreDataManager.delete(sentence: sentence)

        XCTAssertEqual(coreDataManager.fetchAllSentences()?.count, 3)
    }

    func testDeleteAllSentences_afterInsertingMultipleSentences_deletesAllSentences() {
        let coreDataManager = InMemoryCoreDataManager()

        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)
        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)
        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)
        coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)

        coreDataManager.deleteAllSentences()

        XCTAssertEqual(coreDataManager.fetchAllSentences()?.count, 0)
    }

    func testFetchAllSentences_afterInsertingMultipleSentences_returnsAllSentences() {
        let coreDataManager = InMemoryCoreDataManager()

        let card1 = coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)!
        let card2 = coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)!
        let card3 = coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)!
        let card4 = coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)!

        let allCards = coreDataManager.fetchAllSentences()!

        XCTAssertEqual(Set(allCards), Set([card1, card2, card3, card4]))
    }

    func testUpdateSentence_afterInserting_updatesCard() {
        let coreDataManager = InMemoryCoreDataManager()

        let card = coreDataManager.insertSentence(sentence: "Test", definition: "Definition", image: nil)!

        card.sentence = "Test Sentence"
        card.definition = "Test Definition"
        card.imageData = "ABC".data(using: .utf8)

        coreDataManager.update(sentence: card)
        let updatedCard = coreDataManager.fetchAllSentences()![0]

        XCTAssertEqual(updatedCard, card)
    }
}
