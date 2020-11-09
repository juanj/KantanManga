//
//  InMemoryCoreDataManager.swift
//  Kantan-Manga
//
//  Created by Juan on 9/11/20.
//

import Foundation
import CoreData
@testable import Kantan_Manga

class InMemoryCoreDataManager: CoreDataManager {
    override func createContainer() -> NSPersistentContainer {
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        let container = NSPersistentContainer(name: "MangaReader")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        container.loadPersistentStores { _, error in
          if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
          }
        }
        return container
    }
}
