//
//  CoreDataManager.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import CoreData

class CoreDataManager {

    // Make singletone only
    static let sharedManager = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MangaReader")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error when saving context. \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func deleteAllData() {
        deleteAllMangas()
        deleteAllCollections()
    }

    func refreshAll() {
        persistentContainer.viewContext.refreshAllObjects()
    }

    // MARK: - Manga methods
    // MARK: Insert
    @discardableResult
    func insertManga(name: String, coverData: Data, totalPages: Int16, filePath: String, collection: MangaCollection? = nil) -> Manga? {
        let managedContext = persistentContainer.viewContext
        let manga = Manga(context: managedContext, name: name, coverData: coverData, totalPages: totalPages, filePath: filePath, collection: collection)
        do {
            try managedContext.save()
            return manga
        } catch let error as NSError {
            print("Couldn't save Manga. \(error), \(error.userInfo)")
            return nil
        }
    }

    func createMangaWith(filePath path: String, name: String? = nil, collection: MangaCollection? = nil, callback: @escaping (Manga?) -> Void) {
        let fileName = path.lastPathComponent
        let mangaName: String
        if let name = name {
            mangaName = name
        } else {
            mangaName = String(fileName.split(separator: ".").first ?? "")
        }
        let reader: Reader
        do {
            if fileName.lowercased().hasSuffix("cbz") || fileName.lowercased().hasSuffix("zip") {
                reader = try CBZReader(fileName: fileName)
            } else {
                reader = try CBRReader(fileName: fileName)
            }
        } catch {
            print("Error creating reader")
            return
        }
        reader.readFirstEntry { (data) in
            if let data = data {
                let manga = self.insertManga(name: mangaName, coverData: data, totalPages: Int16(reader.numberOfPages), filePath: fileName, collection: collection)
                callback(manga)
            }
        }
    }

    // MARK: Delete
    func delete(manga: Manga) {
        let managedContext = persistentContainer.viewContext
        managedContext.delete(manga)

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't delete Manga \(error), \(error.userInfo)")
        }
    }

    func deleteAllMangas() {
        let fetchRequest = Manga.createFetchRequest()
        do {
            let mangas = try persistentContainer.viewContext.fetch(fetchRequest)
            for case let manga as NSManagedObject in mangas {
                persistentContainer.viewContext.delete(manga)
            }

            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Error when deleting all Mangas. \(error), \(error.userInfo)")
        }
    }

    // MARK: Fetch
    func fetchAllMangas() -> [Manga]? {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = Manga.createFetchRequest()

        do {
            let mangas = try managedContext.fetch(fetchRequest)
            return mangas
        } catch let error as NSError {
            print("Couldn't fetch all Mangas. \(error), \(error.userInfo)")
            return nil
        }
    }

    func getMangaWith(filePath path: String) -> Manga? {
        let context = persistentContainer.viewContext
        let fetchRequest = Manga.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "filePath = %@", path)

        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch let error as NSError {
            print("Could't fetch Manga. \(error), \(error.userInfo)")
            return nil
        }
    }

    func getMangasWithoutCollection() -> [Manga]? {
        let context = persistentContainer.viewContext
        let fetchRequest = Manga.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mangaCollection == nil")

        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            print("Could't fetch Mangas without a collection. \(error), \(error.userInfo)")
            return nil
        }
    }

    // MARK: Update
    func updateManga(manga: Manga) {
        let context = persistentContainer.viewContext
        manga.lastViewedAt = Date()

        do {
            try context.save()
        } catch let error as NSError {
            print("Could not update Manga \(error), \(error.userInfo)")
        }
    }

    // MARK: - MangaCollection methods
    // MARK: Insert
    @discardableResult
    func insertCollection(name: String) -> MangaCollection? {
        let context = persistentContainer.viewContext
        let collection = MangaCollection(context: context, name: name)
        do {
            try context.save()
            return collection
        } catch let error {
            print(error)
            return nil
        }
    }

    // MARK: Delete
    func delete(collection: MangaCollection) {
        let managedContext = persistentContainer.viewContext
        managedContext.delete(collection)

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't delete MangaCollection \(error), \(error.userInfo)")
        }
    }

    func deleteAllCollections() {
        let fetchRequest = MangaCollection.createFetchRequest()
        do {
            let collections = try persistentContainer.viewContext.fetch(fetchRequest)
            for case let collection as NSManagedObject in collections {
                persistentContainer.viewContext.delete(collection)
            }

            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Error when deleting all MangaCollection. \(error), \(error.userInfo)")
        }
    }

    // MARK: Fetch
    func fetchAllCollections() -> [MangaCollection]? {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = MangaCollection.createFetchRequest()

        do {
            let collections = try managedContext.fetch(fetchRequest)
            return collections
        } catch let error as NSError {
            print("Couldn't fetch all MangaCollection. \(error), \(error.userInfo)")
            return nil
        }
    }

    func searchCollectionsWith(name: String) -> [MangaCollection]? {
        let context = persistentContainer.viewContext
        let fetchRequest = MangaCollection.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)

        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could't search MangaCollection. \(error), \(error.userInfo)")
            return nil
        }
    }

    func searchCollectionsStartWith(name: String) -> [MangaCollection]? {
        let context = persistentContainer.viewContext
        let fetchRequest = MangaCollection.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", name)

        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could't search MangaCollection. \(error), \(error.userInfo)")
            return nil
        }
    }

    // MARK: Update
    func updateCollection(_ collection: MangaCollection) {
        let context = persistentContainer.viewContext
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not update Collection \(error), \(error.userInfo)")
        }
    }

    // MARK: Utils
    func createDemoManga(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let filePath = Bundle.main.url(forResource: "demo1", withExtension: "cbz"),
                  let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            var fileName = filePath.lastPathComponent
            var newFileUrl = documentsUrl.appendingPathComponent(fileName)

            if FileManager.default.fileExists(atPath: documentsUrl.appendingPathComponent(fileName).path) {
                let timeStamp = Date().timeIntervalSince1970
                fileName = "\(Int(timeStamp))-\(fileName)"
            }

            newFileUrl = documentsUrl.appendingPathComponent(fileName)

            do {
                try FileManager.default.copyItem(at: filePath, to: newFileUrl)
                guard let collection = self.insertCollection(name: "Demo") else { return }
                self.createMangaWith(filePath: fileName, name: "聖☆おにいさん preview", collection: collection) { _ in
                    completion()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
