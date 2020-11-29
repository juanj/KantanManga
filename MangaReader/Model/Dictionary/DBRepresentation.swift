//
//  DBRepresentation.swift
//  Kantan-Manga
//
//  Created by Juan on 29/11/20.
//

import Foundation
import SQLite

class DBRepresentation {
    struct Dictionaries {
        static let table = Table("dictionaries")

        static let id = Expression<Int64>("id")
        static let title = Expression<String>("title")
        static let revision = Expression<String>("revision")
        static let sequenced = Expression<Bool>("sequenced")
        static let version = Expression<Int64>("version")
        static let author = Expression<String>("author")
        static let url = Expression<String>("url")
        static let description = Expression<String>("description")
        static let attribution = Expression<String>("attribution")

        static func createTable(in db: Connection) throws {
            try db.run(DBRepresentation.Dictionaries.table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(title)
                table.column(revision)
                table.column(sequenced)
                table.column(version)
                table.column(author)
                table.column(url)
                table.column(description)
                table.column(attribution)
            })
        }
    }

    struct Terms {
        static let table = Table("terms")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let expression = Expression<String>("expression")
        static let definitionTags = Expression<String>("definitionTags")
        static let rules = Expression<String>("rules")
        static let score = Expression<Int64>("score")
        static let glossary = Expression<String>("glossary")
        static let sequence = Expression<Int64>("sequence")
        static let termTags = Expression<String>("termTags")

        static func createTable(in db: Connection) throws {
            try db.run(DBRepresentation.Terms.table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary, references: DBRepresentation.Dictionaries.table, DBRepresentation.Dictionaries.id)
                table.column(expression)
                table.column(definitionTags)
                table.column(rules)
                table.column(score)
                table.column(glossary)
                table.column(sequence)
                table.column(termTags)
            })
        }
    }

    struct TermsMeta {
        static let table = Table("termsMeta")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let character = Expression<String>("character")
        static let mode = Expression<String>("mode")

        static func createTable(in db: Connection) throws {
            try db.run(DBRepresentation.TermsMeta.table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary, references: DBRepresentation.Dictionaries.table, DBRepresentation.Dictionaries.id)
                table.column(character)
                table.column(mode)
            })
        }
    }

    struct Kanji {
        static let table = Table("kanji")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let character = Expression<String>("character")
        static let onyomi = Expression<String>("onyomi")
        static let kunyomi = Expression<String>("kunyomi")
        static let tags = Expression<String>("tags")
        static let meanings = Expression<String>("meanings")
        static let stats = Expression<String>("stats")

        static func createTable(in db: Connection) throws {
            try db.run(DBRepresentation.Kanji.table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary, references: DBRepresentation.Dictionaries.table, DBRepresentation.Dictionaries.id)
                table.column(character)
                table.column(onyomi)
                table.column(kunyomi)
                table.column(tags)
                table.column(meanings)
                table.column(stats)
            })
        }
    }

    struct KanjiMeta {
        static let table = Table("kanjiMeta")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let character = Expression<String>("character")
        static let category = Expression<String>("category")

        static func createTable(in db: Connection) throws {
            try db.run(DBRepresentation.KanjiMeta.table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary, references: DBRepresentation.Dictionaries.table, DBRepresentation.Dictionaries.id)
                table.column(character)
                table.column(category)
            })
        }
    }

    struct Tags {
        static let table = Table("tags")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let category = Expression<String>("category")
        static let order = Expression<Int64>("order")
        static let notes = Expression<String>("notes")
        static let score = Expression<Int64>("score")

        static func createTable(in db: Connection) throws {
            try db.run(DBRepresentation.Tags.table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary, references: DBRepresentation.Dictionaries.table, DBRepresentation.Dictionaries.id)
                table.column(category)
                table.column(order)
                table.column(notes)
                table.column(score)
            })
        }
    }
}
