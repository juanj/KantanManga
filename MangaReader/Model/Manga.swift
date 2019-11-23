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
    var coverImage: UIImage?

    override public func awakeFromFetch() {
        super.awakeFromFetch()

        if let data = coverData, let image = UIImage(data: data) {
            coverImage = image
        }
    }
}
