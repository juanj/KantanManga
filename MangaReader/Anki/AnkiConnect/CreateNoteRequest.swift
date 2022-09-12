//
//  CreateNoteRequest.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

struct CreateNoteRequest: Encodable {
    struct Picture: Encodable {
        let filename: String
        let data: String
        let fields: [String]
    }

    private enum CodingKeys: String, CodingKey {
        case model = "modelName"
        case deck = "deckName"
        case fields, picture
    }

    let model: String
    let deck: String
    let fields: [String: String]
    let picture: Picture?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode(deck, forKey: .deck)
        try container.encode(fields, forKey: .fields)
        try container.encode(picture, forKey: .picture)
    }
}
