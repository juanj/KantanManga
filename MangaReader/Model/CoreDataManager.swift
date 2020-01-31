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
        deleteAllCategories()
    }

    // MARK: - Manga methods
    // MARK: Insert
    @discardableResult
    func insertManga(name: String, coverData: Data, totalPages: Int16, filePath: String) -> Manga? {
        let managedContext = persistentContainer.viewContext
        let manga = Manga(context: managedContext, name: name, coverData: coverData, totalPages: totalPages, filePath: filePath)
        do {
            try managedContext.save()
            return manga
        } catch let error as NSError {
            print("Couldn't save Manga. \(error), \(error.userInfo)")
            return nil
        }
    }

    func createMangaWith(filePath path: String, name: String? = nil, callback: @escaping (Manga?) -> Void) {
        let fileName = (path as NSString).lastPathComponent
        let mangaName: String
        if let name = name {
            mangaName = name
        } else {
            mangaName = String(fileName.split(separator: ".").first ?? "")
        }
        guard let reader = try? CBZReader(fileName: fileName) else {
            print("Error creating CBZReader")
            return
        }
        reader.readFirstEntry { (data) in
            if let data = data {
                let manga = self.insertManga(name: mangaName, coverData: data, totalPages: Int16(reader.numberOfPages), filePath: fileName)
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

    // MARK: - MangaCategory methods
    // MARK: Insert
    @discardableResult
    func insertCategory(name: String) -> MangaCategory? {
        let context = persistentContainer.viewContext
        let category = MangaCategory(context: context, name: name)
        do {
            try context.save()
            return category
        } catch let error {
            print(error)
            return nil
        }
    }

    // MARK: Delete
    func delete(category: MangaCategory) {
        let managedContext = persistentContainer.viewContext
        managedContext.delete(category)

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't delete MangaCategory \(error), \(error.userInfo)")
        }
    }

    func deleteAllCategories() {
        let fetchRequest = MangaCategory.createFetchRequest()
        do {
            let categories = try persistentContainer.viewContext.fetch(fetchRequest)
            for case let category as NSManagedObject in categories {
                persistentContainer.viewContext.delete(category)
            }

            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Error when deleting all MangaCategories. \(error), \(error.userInfo)")
        }
    }

    // MARK: Fetch
    func fetchAllCategoties() -> [MangaCategory]? {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = MangaCategory.createFetchRequest()

        do {
            let categories = try managedContext.fetch(fetchRequest)
            return categories
        } catch let error as NSError {
            print("Couldn't fetch all MangaCategories. \(error), \(error.userInfo)")
            return nil
        }
    }

    func searchCategoriesWith(name: String) -> [MangaCategory]? {
        let context = persistentContainer.viewContext
        let fetchRequest = MangaCategory.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)

        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could't search MangaCategories. \(error), \(error.userInfo)")
            return nil
        }
    }
}
