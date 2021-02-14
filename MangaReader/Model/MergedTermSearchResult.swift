//
//  MergedTermSearchResult.swift
//  Kantan-Manga
//
//  Created by Juan on 18/01/21.
//

import Foundation

struct MergedTermSearchResult {
    let expression: String
    let reading: String
    var terms: [SearchTermResult]
    var meta: [TermMetaSearchResult]
}
