//
//  DBRepresentation.swift
//  Kantan-Manga
//
//  Created by Juan on 29/11/20.
//

import Foundation
import SQLite

class DBRepresentation {
    static let encoder = JSONEncoder()
    struct Dictionaries {
        static let table = Table("dictionaries")

        static let id = Expression<Int64>("id")
        static let title = Expression<String>("title")
        static let revision = Expression<String>("revision")
        static let sequenced = Expression<Bool?>("sequenced")
        static let version = Expression<Int64>("version")
        static let author = Expression<String?>("author")
        static let url = Expression<String?>("url")
        static let description = Expression<String?>("description")
        static let attribution = Expression<String?>("attribution")

        static func createTable(in db: Connection) throws {
            try db.run(table.create { table in
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

        static func insert(in db: Connection, index: DictionaryIndex) throws -> Int64 {
            return try db.run(table.insert(
                title <- index.title,
                revision <- index.revision,
                sequenced <- index.sequenced,
                version <- Int64(index.fileVersion.rawValue),
                author <- index.author,
                url <- index.author,
                description <- index.description,
                attribution <- index.attribution
            ))
        }

        static func toDictionaryIndex(_ row: Row) -> DictionaryIndex? {
            let version = DictionaryIndex.Version(rawValue: Int(row[self.version])) ?? .v3
            return DictionaryIndex(title: row[title], revision: row[revision], sequenced: row[sequenced], format: version, version: version, author: row[author], url: row[url], description: row[description], attribution: row[attribution])
        }

        static func deleteQuery(id: Int64) -> Table {
            return table.filter(self.id == id)
        }
    }

    struct Terms {
        static let table = Table("terms")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let expression = Expression<String>("expression")
        static let reading = Expression<String>("reading")
        static let definitionTags = Expression<String?>("definitionTags")
        static let rules = Expression<String>("rules")
        static let score = Expression<Int64>("score")
        static let glossary = Expression<String>("glossary")
        static let sequence = Expression<Int64>("sequence")
        static let termTags = Expression<String>("termTags")

        static func createTable(in db: Connection) throws {
            try db.run(table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary)
                table.column(expression)
                table.column(reading)
                table.column(definitionTags)
                table.column(rules)
                table.column(score)
                table.column(glossary)
                table.column(sequence)
                table.column(termTags)
                table.foreignKey(dictionary, references: Dictionaries.table, Dictionaries.id, delete: .cascade)
            })
        }

        static func insert(in db: Connection, term: TermEntry, dictionary: Int64) throws {
            let glossary = String(data: try encoder.encode(term.glossary), encoding: .utf8) ?? ""
            try db.run(table.insert(
                self.dictionary <- dictionary,
                expression <- term.expression,
                reading <- term.reading,
                definitionTags <- term.definitionTags,
                rules <- term.rules,
                score <- Int64(term.score),
                self.glossary <- glossary,
                sequence <- Int64(term.sequence),
                termTags <- term.termTags
            ))
        }

        static func searchQuery(term: String) -> Table {
            table.filter(expression.like(term) || reading.like(term))
        }

        static func toDictionaryResult(_ row: Row) -> DictionaryResult? {
            let expression = row[self.expression]
            let reading = row[self.reading]
            guard let glossary = row[self.glossary].data(using: .utf8) else { return nil }
            let decoder = JSONDecoder()
            do {
                let meanings = try decoder.decode([GlossaryItem].self, from: glossary)
                return DictionaryResult(term: expression, reading: reading, meanings: meanings)
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
    }

    struct TermsMeta {
        static let table = Table("termsMeta")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let character = Expression<String>("character")
        static let mode = Expression<String>("mode")

        static func createTable(in db: Connection) throws {
            try db.run(table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary)
                table.column(character)
                table.column(mode)
                table.foreignKey(dictionary, references: Dictionaries.table, Dictionaries.id, delete: .cascade)
            })
        }

        static func insert(in db: Connection, termMeta: TermMetaEntry, dictionary: Int64) throws {
            let mode = String(data: try encoder.encode(termMeta.mode), encoding: .utf8) ?? ""
            try db.run(table.insert(
                self.dictionary <- dictionary,
                character <- termMeta.character,
                self.mode <- mode
            ))
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
            try db.run(table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary)
                table.column(character)
                table.column(onyomi)
                table.column(kunyomi)
                table.column(tags)
                table.column(meanings)
                table.column(stats)
                table.foreignKey(dictionary, references: Dictionaries.table, Dictionaries.id, delete: .cascade)
            })
        }

        static func insert(in db: Connection, kanji: KanjiEntry, dictionary: Int64) throws {
            let meanings = try encoder.encode(kanji.meanings)
            let stats = try encoder.encode(kanji.stats)
            try db.run(table.insert(
                self.dictionary <- dictionary,
                character <- kanji.character,
                onyomi <- kanji.onyomi,
                kunyomi <- kanji.kunyomi,
                tags <- kanji.tags,
                self.meanings <- String(data: meanings, encoding: .utf8) ?? "",
                self.stats <- String(data: stats, encoding: .utf8) ?? ""
            ))
        }
    }

    struct KanjiMeta {
        static let table = Table("kanjiMeta")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let character = Expression<String>("character")
        static let category = Expression<String>("category")

        static func createTable(in db: Connection) throws {
            try db.run(table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary)
                table.column(character)
                table.column(category)
                table.foreignKey(dictionary, references: Dictionaries.table, Dictionaries.id, delete: .cascade)
            })
        }

        static func insert(in db: Connection, kanjiMeta: KanjiMetaEntry, dictionary: Int64) throws {
            let category = try encoder.encode(kanjiMeta.category)
            try db.run(table.insert(
                self.dictionary <- dictionary,
                character <- kanjiMeta.character,
                self.category <- String(data: category, encoding: .utf8) ?? ""
            ))
        }
    }

    struct Tags {
        static let table = Table("tags")

        static let id = Expression<Int64>("id")
        static let dictionary = Expression<Int64>("dictionary")
        static let category = Expression<String>("category")
        static let order = Expression<Int64?>("order")
        static let notes = Expression<String>("notes")
        static let score = Expression<Int64>("score")

        static func createTable(in db: Connection) throws {
            try db.run(table.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(dictionary)
                table.column(category)
                table.column(order)
                table.column(notes)
                table.column(score)
                table.foreignKey(dictionary, references: Dictionaries.table, Dictionaries.id, delete: .cascade)
            })
        }

        static func insert(in db: Connection, tag: TagEntry, dictionary: Int64) throws {
            try db.run(table.insert(
                self.dictionary <- dictionary,
                category <- tag.category,
                order <- Int64(tag.order),
                notes <- tag.notes,
                score <- Int64(tag.score)
            ))
        }
    }
}
