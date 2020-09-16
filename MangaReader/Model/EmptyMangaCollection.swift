//
//  EmptyMangaCollection.swift
//  Kantan-Manga
//
//  Created by Juan on 16/09/20.
//

import Foundation

class EmptyMangaCollection: MangaCollectionable {
    var name: String? = "No Collection"
    var mangas: [Manga]

    init(mangas: [Manga]) {
        self.mangas = mangas
    }
}
