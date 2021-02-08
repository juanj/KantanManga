//
//  CoreDataManageable.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import Foundation
import CoreData

protocol CoreDataManageable {
    func saveContext ()
    func deleteAllData()
    func refreshAll()
    @discardableResult
    func insertManga(name: String, coverData: Data, totalPages: Int16, filePath: String, collection: MangaCollection?) -> Manga?
    func createMangaWith(filePath path: String, name: String?, collection: MangaCollection?, completion: @escaping (Manga?) -> Void)
    func delete(manga: Manga)
    func deleteAllMangas()
    func fetchAllMangas() -> [Manga]?
    func getMangaWith(filePath path: String) -> Manga?
    func getMangasWithoutCollection() -> [Manga]?
    func updateManga(manga: Manga)
    @discardableResult
    func insertCollection(name: String) -> MangaCollection?
    func delete(collection: MangaCollection)
    func deleteAllCollections()
    func fetchAllCollections() -> [MangaCollection]?
    func searchCollectionsWith(name: String) -> [MangaCollection]?
    func searchCollectionsStartWith(name: String) -> [MangaCollection]?
    func updateCollection(_ collection: MangaCollection)
    func createDemoManga(completion: @escaping () -> Void)
}
