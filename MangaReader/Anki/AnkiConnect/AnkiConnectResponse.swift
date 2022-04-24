//
//  AnkiConnectResponse.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

struct AnkiConnectResponse<Result: Decodable>: Decodable {
    let result: Result?
    let error: String?
}
