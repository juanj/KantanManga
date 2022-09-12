//
//  Sentence+CoreDataProperties.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import CoreData

extension Sentence {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Sentence> {
        return NSFetchRequest<Sentence>(entityName: "Sentence")
    }

    @NSManaged public var word: String
    @NSManaged public var reading: String
    @NSManaged public var sentence: String
    @NSManaged public var definition: String
    @NSManaged var imageData: Data?
}
