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

enum GlossaryItem {
    case text(String)
    case image(path: String, width: Int?, height: Int?, title: String?, description: String?, pixelated: Bool = false)
}

extension GlossaryItem: CustomStringConvertible {
    var description: String {
        switch self {
        case .text(let text):
            return text
        case .image(let path, let width, let height, let title, let description, let pixelated):
            return "(\(path), \(width ?? 0), \(height ?? 0), \(title ?? ""), \(description ?? ""), \(pixelated))"
        }
    }
}
