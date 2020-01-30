//
//  MangaCategory.swift
//  MangaReader
//
//  Created by DevBakura on 29/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import CoreData

@objc(MangaCategory)
public class MangaCategory: NSManagedObject {
    convenience init(context: NSManagedObjectContext, name: String) {
        self.init(context: context)
        self.name = name
    }
}
