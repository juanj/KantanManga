//
//  Term.swift
//  Kantan-Manga
//
//  Created by Juan on 8/12/20.
//

import Foundation
import GRDB

struct Term {
    let id: Int // = Expression<Int64>("id")
    let dictionary: Int // = Expression<Int64>("dictionary")
    let expression: String // = Expression<String>("expression")
    let reading: String // = Expression<String>("reading")
    let definitionTags: String? // = Expression<String?>("definitionTags")
    let rules: String // = Expression<String>("rules")
    let score: Int // = Expression<Int64>("score")
    let glossary: String // = Expression<String>("glossary")
    let sequence: Int // = Expression<Int64>("sequence")
    let termTags: String // = Expression<String>("termTags")
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
