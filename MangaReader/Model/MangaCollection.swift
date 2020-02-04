//
//  MangaCollection.swift
//  MangaReader
//
//  Created by Juan on 4/02/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import CoreData

@objc(MangaCollection)
public class MangaCollection: NSManagedObject {
  convenience init(context: NSManagedObjectContext, name: String) {
    self.init(context: context)
    self.name = name
  }
}
