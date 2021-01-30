//
//  TermEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

protocol TermEntry: CustomStringConvertible {
    var expression: String { get }
    var reading: String { get }
    var definitionTags: String? { get }
    var rules: String { get }
    var score: Int { get }
    var glossary: [GlossaryItem] { get }
    var sequence: Int { get }
    var termTags: String { get }
}

extension TermEntry {
    var description: String {
        return "\(expression), \(reading), \(definitionTags ?? ""), \(rules), \(score), [\(glossary.map { $0.description }.joined(separator: ","))], \(sequence), \(termTags)"
    }
}
