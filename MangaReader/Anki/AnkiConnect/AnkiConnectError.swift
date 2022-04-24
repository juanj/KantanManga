//
//  AnkiConnectError.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

struct AnkiConnectError: LocalizedError {
    let description: String
    var errorDescription: String? { description }
}
