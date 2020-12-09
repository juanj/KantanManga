//
//  Term.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Term {
    let id: Int
    let dictionary: Int
    let expression: String
    let reading: String
    let definitionTags: String?
    let rules: String
    let score: Int
    let glossary: String
    let sequence: Int
    let termTags: String
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
        glossary = row[Columns.glossary]
        sequence = row[Columns.sequence]
        termTags = row[Columns.termTags]
    }
}
