//
//  Term.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Term {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    var id: Int?
    let dictionary: Int
    let expression: String
    let reading: String
    let definitionTags: String?
    let rules: String
    let score: Int
    let glossary: [GlossaryItem]
    let sequence: Int
    let termTags: String

    init(from termEntry: TermEntry, dictionaryId: Int) {
        id = nil
        dictionary = dictionaryId
        expression = termEntry.expression
        reading = termEntry.reading
        definitionTags = termEntry.definitionTags
        rules = termEntry.rules
        score = termEntry.score
        glossary = termEntry.glossary
        sequence = termEntry.sequence
        termTags = termEntry.termTags
    }
}

extension Term: TableRecord {
    enum Columns: String, ColumnExpression {
        case id, dictionary, expression, reading, definitionTags, rules, score, glossary, sequence, termTags
    }

    static var databaseTableName = "terms"
}

extension Term: FetchableRecord {
    init(row: Row) {
        id = row[Columns.id]
        dictionary = row[Columns.dictionary]
        expression = row[Columns.expression]
        reading = row[Columns.reading]
        definitionTags = row[Columns.definitionTags]
        rules = row[Columns.rules]
        score = row[Columns.score]
        sequence = row[Columns.sequence]
        termTags = row[Columns.termTags]

        let glossary: String = row[Columns.glossary]
        self.glossary = (try? Term.decoder.decode([GlossaryItem].self, from: glossary.data(using: .utf8) ?? Data())) ?? []
    }
}

extension Term: MutablePersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.dictionary] = dictionary
        container[Columns.expression] = expression
        container[Columns.reading] = reading
        container[Columns.definitionTags] = definitionTags
        container[Columns.rules] = rules
        container[Columns.score] = score
        container[Columns.sequence] = sequence
        container[Columns.termTags] = termTags

        // For some reason JSONEncoder delays memory release causing a huge memory usage
        // Adding an autorelease pool solves the issue
        autoreleasepool {
            container[Columns.glossary] = (try? Term.encoder.encode(glossary)) ?? ""
        }
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }
}
