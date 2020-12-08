//
//  Dictionary.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Dictionary {
    let id: Int
    let title: String
    let revision: String
    let sequenced: Bool?
    let version: Int64
    let author: String?
    let url: String?
    let description: String?
    let attribution: String
}

extension Dictionary: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, title, revision, sequenced, version, author, url, description, attribution
    }

    static var databaseTableName = "dictionaries"
}

extension Dictionary: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        title = row[Columns.title]
        revision = row[Columns.revision]
        sequenced = row[Columns.sequenced]
        version = row[Columns.version]
        author = row[Columns.author]
        url = row[Columns.url]
        description = row[Columns.description]
        attribution = row[Columns.attribution]
    }
}
