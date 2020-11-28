//
//  KanjiMetaEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct KanjiMetaEntry {
    enum Category {
        case freq
    }

    let character: String
    let category: Category
    let data: String
}
