//
//  CoreDataManager.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import CoreData

class CoreDataManager {
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
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func insertManga(totalPages: Int16, filePath: String, currentPage: Int16 = 0, coverImage: Data = Data()) -> Manga? {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext

        let manga = Manga(context: managedContext)
        manga.totalPages = totalPages
        manga.filePath = filePath
        manga.currentPage = currentPage
        manga.coverData = coverImage
        manga.createdAt = Date()
        manga.lastViewedAt = Date()

        do {
            try managedContext.save()
            return manga
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }

    func update(manga: Manga, totalPages: Int16, filePath: String, currentPage: Int16, coverImage: Data) {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext

        manga.totalPages = totalPages
        manga.filePath = filePath
        manga.currentPage = currentPage
        manga.coverData = coverImage
        manga.lastViewedAt = Date()

        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    func updatePage(manga: Manga, newPage: Int16) {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext

        manga.currentPage = newPage
        manga.lastViewedAt = Date()

        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    func delete(manga: Manga) {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        managedContext.delete(manga)

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    func fetchAllMangas() -> [Manga]? {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Manga")

        do {
            let mangas = try managedContext.fetch(fetchRequest)
            return mangas as? [Manga]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }

    }

    func flushData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> =
            NSFetchRequest<NSFetchRequestResult>(entityName: "Manga")
        do {
            let objs = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(fetchRequest)
            for case let obj as NSManagedObject in objs {
                CoreDataManager.sharedManager.persistentContainer.viewContext.delete(obj)
            }

            try CoreDataManager.sharedManager.persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not flush data. \(error), \(error.userInfo)")
        }
    }

    func createMangaWith(filePath path: String) {
        do {
            let fileName = (path as NSString).lastPathComponent
            let reader = try CBZReader(fileName: fileName)
            reader.readFirstEntry { (data) in
                if let data = data {
                    _ = CoreDataManager.sharedManager.insertManga(totalPages: Int16(reader.numberOfPages), filePath: fileName, currentPage: 0, coverImage: data)
                }
            }
        } catch {
            print("Error creating CBZReader")
        }
    }

    func getMangaWith(filePath path: String) -> Manga? {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Manga")
        fetchRequest.predicate = NSPredicate(format: "filePath=%@", path)

        do {
            let manga = try context.fetch(fetchRequest)
            if manga.count > 0 {
                return manga[0] as? Manga
            } else {
                return nil
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
}
