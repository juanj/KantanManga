//
//  DictionaryIndex.swift
//  Kantan-Manga
//
//  Created by Juan on 27/11/20.
//

import Foundation

struct DictionaryIndex: Decodable {
    let title: String
    let revision: String
    let sequenced: Bool?
    let format: Int?
    let version: Int?
    let author: String?
    let url: String?
    let description: String?
    let attribution: String?
}
