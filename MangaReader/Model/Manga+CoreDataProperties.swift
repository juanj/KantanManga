//
//  Manga+CoreDataProperties.swift
//  MangaReader
//
//  Created by admin on 2/25/19.
//  Copyright © 2019 Bakura. All rights reserved.
//
//

import Foundation
import CoreData

extension Manga {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Manga> {
        return NSFetchRequest<Manga>(entityName: "Manga")
    }

    @NSManaged public var coverData: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var currentPage: Int16
    @NSManaged public var filePath: String?
    @NSManaged public var lastViewedAt: Date?
    @NSManaged public var totalPages: Int16

}
