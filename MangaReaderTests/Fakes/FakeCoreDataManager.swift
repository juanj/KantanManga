//
//  FakeCoreDataManager.swift
//  Kantan-Manga
//
//  Created by Juan on 7/11/20.
//

import Foundation
@testable import Kantan_Manga

class FakeCoreDataManager: CoreDataManageable {
    var mangas = [Manga]()
    func saveContext() {}
    func deleteAllData() {}
    func refreshAll() {}

    func insertManga(name: String, coverData: Data, totalPages: Int16, filePath: String, collection: MangaCollection?) -> Manga? {
        return nil
    }

    func createMangaWith(filePath path: String, name: String?, collection: MangaCollection?, callback: @escaping (Manga?) -> Void) {}
    func delete(manga: Manga) {}
    func deleteAllMangas() {}

    func fetchAllMangas() -> [Manga]? {
        return []
    }
    func getMangaWith(filePath path: String) -> Manga? {
        return nil
    }

    func getMangasWithoutCollection() -> [Manga]? {
        return mangas
    }

    func updateManga(manga: Manga) {}

    func insertCollection(name: String) -> MangaCollection? {
        return nil
    }

    func delete(collection: MangaCollection) {}
    func deleteAllCollections() {}

    func fetchAllCollections() -> [MangaCollection]? {
        return []
    }

    func searchCollectionsWith(name: String) -> [MangaCollection]? {
        return []
    }

    func searchCollectionsStartWith(name: String) -> [MangaCollection]? {
        return []
    }

    func updateCollection(_ collection: MangaCollection) {}
    func createDemoManga(completion: @escaping () -> Void) {}
}
