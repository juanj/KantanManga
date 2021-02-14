//
//  Sequence+Extension.swift
//  Kantan-Manga
//
//  Created by Juan on 14/02/21.
//

import Foundation

extension Sequence {
    func keyedBy(_ keyPath: KeyPath<Element, String>) -> [String: Element] {
        reduce([String: Element](), {
            var dict = $0
            dict[$1[keyPath: keyPath]] = $1
            return dict
        })
    }
}
