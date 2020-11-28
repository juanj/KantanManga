//
//  TermEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

protocol TermEntry {
    var expression: String { get }
    var reading: String { get }
    var definitionTags: String? { get }
    var rules: String { get }
    var score: Int { get }
    var glossary: [String] { get } // TODO: implement detailed definitions
    var sequence: Int { get }
    var termTags: String { get }
}
