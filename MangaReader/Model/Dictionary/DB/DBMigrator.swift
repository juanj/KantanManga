//
//  DBMigrator.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct DBMigrator {
    private var migrator = DatabaseMigrator()
    init() {
        registerMigrations()
    }

    private mutating func registerMigrations() {
        registerV1Migration()
    }

    // swiftlint:disable:next function_body_length
    private mutating func registerV1Migration() {
        migrator.registerMigration("v1") { db in
            try db.create(table: "dictionaries", body: { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("title", .text).notNull()
                table.column("revision", .text).notNull()
                table.column("sequenced", .integer)
                table.column("version", .double).notNull()
                table.column("author", .text)
                table.column("url", .text)
                table.column("description", .text)
                table.column("attribution", .text)
            })

            try db.create(table: "terms", body: { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("expression", .text).notNull()
                table.column("reading", .text).notNull()
                table.column("definitionTags", .text)
                table.column("rules", .text).notNull()
                table.column("score", .integer).notNull()
                table.column("glossary", .text).notNull()
                table.column("sequence", .integer).notNull()
                table.column("termTags", .text).notNull()
                table.column("dictionary").references("dictionaries", onDelete: .cascade).notNull()
            })

            try db.create(table: "termsMeta", body: { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("character", .text).notNull()
                table.column("mode", .text).notNull()
                table.column("dictionary").references("dictionaries", onDelete: .cascade).notNull()
            })

            try db.create(table: "kanji", body: { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("character", .text).notNull()
                table.column("onyomi", .text).notNull()
                table.column("kunyomi", .text).notNull()
                table.column("tags", .text).notNull()
                table.column("meanings", .text).notNull()
                table.column("stats", .text).notNull()
                table.column("dictionary").references("dictionaries", onDelete: .cascade).notNull()
            })

            try db.create(table: "kanjiMeta", body: { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("character", .text).notNull()
                table.column("category", .text).notNull()
                table.column("dictionary").references("dictionaries", onDelete: .cascade).notNull()
            })

            try db.create(table: "tags", body: { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("category", .text).notNull()
                table.column("order", .integer)
                table.column("notes", .text).notNull()
                table.column("score", .integer).notNull()
                table.column("dictionary").references("dictionaries", onDelete: .cascade).notNull()
            })
        }
    }

    func migrate(db: DatabaseWriter) throws {
        try migrator.migrate(db)
    }
}
