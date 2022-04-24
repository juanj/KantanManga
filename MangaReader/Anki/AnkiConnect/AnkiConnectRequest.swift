//
//  AnkiConnectRequest.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

struct AnkiConnectRequest<Params: Encodable>: Encodable {
    let action: String
    let version: Int
    let params: Params?
    let key: String?
}
