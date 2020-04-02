//
//  Manga+CoreDataClass.swift
//  MangaReader
//
//  Created by admin on 2/25/19.
//  Copyright © 2019 Bakura. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Manga)
public class Manga: NSManagedObject {
    private(set) public var coverImage: UIImage?

    internal convenience init(context: NSManagedObjectContext, name: String, coverData: Data, totalPages: Int16, filePath: String, collection: MangaCollection? = nil, currentPage: Int16 = 0, createdAt: Date = Date(), lastViewedAt: Date? = nil) {
        self.init(context: context)
        self.name = name
        self.coverData = coverData
        self.totalPages = totalPages
        self.filePath = filePath
        self.currentPage = currentPage
        self.createdAt = createdAt
        self.lastViewedAt = lastViewedAt
        mangaCollection = collection
    }

    override public func awakeFromFetch() {
        super.awakeFromFetch()

        // Preload image data
        loadCoverImage()
    }

    public func loadCoverImage() {
        if let data = coverData, let image = UIImage(data: data) {
            coverImage = image
        }
    }
}
