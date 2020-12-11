//
//  Dictionary.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Dictionary {
    private(set) var id: Int?
    let title: String
    let revision: String
    let sequenced: Bool?
    let version: Int
    let author: String?
    let url: String?
    let description: String?
    let attribution: String?

    init(from index: DictionaryIndex) {
        id = nil
        title = index.title
        revision = index.revision
        sequenced = index.sequenced
        version = index.fileVersion.rawValue
        author = index.author
        url = index.url
        description = index.description
        attribution = index.attribution
    }
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

extension Dictionary: MutablePersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.title] = title
        container[Columns.revision] = revision
        container[Columns.sequenced] = sequenced
        container[Columns.version] = version
        container[Columns.author] = author
        container[Columns.url] = url
        container[Columns.description] = description
        container[Columns.attribution] = attribution
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }
}
