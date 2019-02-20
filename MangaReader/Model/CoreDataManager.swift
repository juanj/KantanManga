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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
    
    func insertManga(title: String, totalPages: Int16, filePath: String, currentPage: Int16 = 0, coverImage: Data = Data()) -> Manga? {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Manga", in: managedContext)!

        let manga = NSManagedObject(entity: entity, insertInto: managedContext)
        manga.setValue(title, forKeyPath: "title")
        manga.setValue(totalPages, forKeyPath: "totalPages")
        manga.setValue(filePath, forKeyPath: "filePath")
        manga.setValue(currentPage, forKeyPath: "currentPage")
        manga.setValue(coverImage, forKeyPath: "coverImage")
        
        do {
            try managedContext.save()
            return manga as? Manga
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func update(manga: Manga, title: String, totalPages: Int16, filePath: String, currentPage: Int16, coverImage: Data) {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        manga.title = title
        manga.totalPages = totalPages
        manga.filePath = filePath
        manga.currentPage = currentPage
        manga.coverImage = coverImage
        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func delete(manga : Manga) {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        managedContext.delete(manga)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func fetchAllMangass() -> [Manga]?{
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
}
