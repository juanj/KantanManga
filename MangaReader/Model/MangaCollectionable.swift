//
//  MangaCollectionable.swift
//  Kantan-Manga
//
//  Created by Juan on 16/09/20.
//

import Foundation

protocol MangaCollectionable {
    var name: String? { get }
    var mangas: [Manga] { get }
}
