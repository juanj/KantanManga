//
//  CoreDataManager.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import CoreData

class CoreDataManager: CoreDataManageable {
    private lazy var persistentContainer: NSPersistentContainer = createContainer()
    private var managedContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func createContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "MangaReader")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }

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

    @discardableResult
    private func saveContextOrPrintError(action: String = "") -> Bool {
        var saved = false
        do {
            try managedContext.save()
            saved = true
        } catch let error as NSError {
            print("CoreData error at \(action). \(error)")
        }
        return saved
    }

    private func deleteOrPrintError<T>(_ request: NSFetchRequest<T>) {
        do {
            let objects = try managedContext.fetch(request)
            for case let object as NSManagedObject in objects {
                managedContext.delete(object)
            }
        } catch let error as NSError {
            print("Error deleting \(request.entityName ?? "object"). \(error), \(error.userInfo)")
        }
    }

    private func fetchOrPrintError<T>(_ request: NSFetchRequest<T>) -> [T]? {
        do {
            let object = try managedContext.fetch(request)
            return object
        } catch let error as NSError {
            print("Couldn't fetch \(request.entityName ?? "object"). \(error), \(error.userInfo)")
            return nil
        }
    }

    // MARK: - Manga methods
    // MARK: Insert
    @discardableResult
    func insertManga(name: String, coverData: Data, totalPages: Int16, filePath: String, collection: MangaCollection? = nil) -> Manga? {
        let manga = Manga(context: managedContext, name: name, coverData: coverData, totalPages: totalPages, filePath: filePath, collection: collection)
        if saveContextOrPrintError(action: "insert manga") {
            return manga
        }
        return nil
    }

    func createMangaWith(filePath path: String, name: String? = nil, collection: MangaCollection? = nil, completion: @escaping (Manga?) -> Void) {
        let fileName = path.lastPathComponent
        let mangaName: String
        if let name = name {
            mangaName = name
        } else {
            mangaName = String(fileName.split(separator: ".").first ?? "")
        }
        let reader: Reader
        do {
            reader = try GenericReader(fileName: fileName)
        } catch let error {
            print("Error creating reader: \(error.localizedDescription)")
            return
        }
        reader.readFirstImageEntry { (data) in
            if let data = data {
                let manga = self.insertManga(name: mangaName, coverData: data, totalPages: Int16(reader.numberOfPages), filePath: fileName, collection: collection)
                completion(manga)
            }
        }
    }

    // MARK: Delete
    func delete(manga: Manga) {
        managedContext.delete(manga)
        saveContextOrPrintError(action: "delete manga")
    }

    func deleteAllMangas() {
        let fetchRequest = Manga.createFetchRequest()
        deleteOrPrintError(fetchRequest)
        saveContextOrPrintError(action: "delete all mangas")
    }

    // MARK: Fetch
    func fetchAllMangas() -> [Manga]? {
        let fetchRequest = Manga.createFetchRequest()
        return fetchOrPrintError(fetchRequest)
    }

    func getMangaWith(filePath path: String) -> Manga? {
        let fetchRequest = Manga.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "filePath = %@", path)

        return fetchOrPrintError(fetchRequest)?.first
    }

    func getMangasWithoutCollection() -> [Manga]? {
        let fetchRequest = Manga.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mangaCollection == nil")

        return fetchOrPrintError(fetchRequest)
    }

    // MARK: Update
    func updateManga(manga: Manga) {
        manga.lastViewedAt = Date()

        saveContextOrPrintError(action: "update manga")
    }

    // MARK: - MangaCollection methods
    // MARK: Insert
    @discardableResult
    func insertCollection(name: String) -> MangaCollection? {
        let collection = MangaCollection(context: managedContext, name: name)
        if saveContextOrPrintError(action: "insert collection") {
            return collection
        }
        return nil
    }

    // MARK: Delete
    func delete(collection: MangaCollection) {
        managedContext.delete(collection)
        saveContextOrPrintError(action: "delete collection")
    }

    func deleteAllCollections() {
        let fetchRequest = MangaCollection.createFetchRequest()
        deleteOrPrintError(fetchRequest)
        saveContextOrPrintError(action: "delete all collections")
    }

    // MARK: Fetch
    func fetchAllCollections() -> [MangaCollection]? {
        let fetchRequest = MangaCollection.createFetchRequest()
        return fetchOrPrintError(fetchRequest)
    }

    func searchCollectionsWith(name: String) -> [MangaCollection]? {
        let fetchRequest = MangaCollection.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)

        return fetchOrPrintError(fetchRequest)
    }

    func searchCollectionsStartWith(name: String) -> [MangaCollection]? {
        let fetchRequest = MangaCollection.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", name)

        return fetchOrPrintError(fetchRequest)
    }

    // MARK: Update
    func updateCollection(_ collection: MangaCollection) {
        saveContextOrPrintError(action: "update collection")
    }

    // MARK: Sentence Methods
    @discardableResult
    func insertSentence(word: String, reading: String, sentence: String, definition: String, image: UIImage?) -> Sentence? {
        let managedContext = persistentContainer.viewContext
        let sentence = Sentence(context: managedContext, word: word, reading: reading, sentence: sentence, definition: definition, image: image)
        if saveContextOrPrintError(action: "insert sentence") {
            return sentence
        }
        return nil
    }

    func delete(sentence: Sentence) {
        managedContext.delete(sentence)
        saveContextOrPrintError(action: "delete sentence")
    }

    func deleteAllSentences() {
        let fetchRequest = Sentence.createFetchRequest()
        deleteOrPrintError(fetchRequest)
        saveContextOrPrintError(action: "delete all sentences")
    }

    func fetchAllSentences() -> [Sentence]? {
        let fetchRequest = Sentence.createFetchRequest()
        return fetchOrPrintError(fetchRequest)
    }

    func update(sentence: Sentence) {
        saveContextOrPrintError(action: "update sentence")
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
                guard let collection = self.insertCollection(name: "Demo Collection") else { return }
                self.createMangaWith(filePath: fileName, name: "聖☆おにいさん preview", collection: collection) { _ in
                    completion()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
