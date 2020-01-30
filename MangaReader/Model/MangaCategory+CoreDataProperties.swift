//
//  MangaCategory+CoreDataProperties.swift
//  MangaReader
//
//  Created by DevBakura on 29/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation
import CoreData

extension MangaCategory {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<MangaCategory> {
        return NSFetchRequest<MangaCategory>(entityName: "MangaCategory")
    }
    
    var mangas: [Manga] {
        return Array(mangasWithCategory ?? [])
    }
    @NSManaged public var name: String?
    @NSManaged private var mangasWithCategory: Set<Manga>?
}
