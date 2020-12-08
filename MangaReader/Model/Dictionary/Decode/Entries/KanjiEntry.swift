//
//  KanjiEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

protocol KanjiEntry: CustomStringConvertible {
    var character: String { get }
    var onyomi: String { get }
    var kunyomi: String { get }
    var tags: String { get }
    var meanings: [String] { get }
    var stats: [String: String] { get }
}

extension KanjiEntry {
    var description: String {
        return "\(character), (\(onyomi)), (\(kunyomi)), (\(tags)), \(meanings), \(stats.sorted { $0.key > $1.key })"
    }
}
