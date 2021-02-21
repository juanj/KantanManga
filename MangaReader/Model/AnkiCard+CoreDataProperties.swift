//
//  AnkiCard+CoreDataProperties.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import CoreData

extension AnkiCard {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<AnkiCard> {
        return NSFetchRequest<AnkiCard>(entityName: "AnkiCard")
    }

    @NSManaged public var sentence: String
    @NSManaged public var definition: String
    @NSManaged var imageData: Data?
}
