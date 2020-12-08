//
//  DBRepresentation.swift
//  Kantan-Manga
//
//  Created by Juan on 29/11/20.
//

import Foundation

class DBRepresentation {
    static let encoder = JSONEncoder()
    struct Dictionaries {

       /*static func createTable(in db: Connection) throws {
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
        }*/
    }

    struct Terms {
        /*static func createTable(in db: Connection) throws {
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
        }*/
    }

    struct TermsMeta {
        /*static func createTable(in db: Connection) throws {
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
        }*/
    }

    struct Kanji {
        /*static func createTable(in db: Connection) throws {
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
        }*/
    }

    struct KanjiMeta {
        /*
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
        }*/
    }

    struct Tags {
        /*static func createTable(in db: Connection) throws {
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
        }*/
    }
}
