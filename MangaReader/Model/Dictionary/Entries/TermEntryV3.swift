//
//  TermEntryV3.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct TermEntryV3: TermEntry {
    let expression: String
    let reading: String
    let definitionTags: String?
    let rules: String
    let score: Int
    let glossary: [GlossaryItem]
    let sequence: Int
    let termTags: String
}

extension TermEntryV3: Decodable {
    private enum GlossaryKeys: String, CodingKey {
        case type, text, path, width, height, title, description, pixelated
    }

    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        expression = try values.decode(String.self)
        reading = try values.decode(String.self)
        definitionTags = try? values.decode(String.self)
        rules = try values.decode(String.self)
        score = try values.decode(Int.self)

        var items = try values.nestedUnkeyedContainer()
        var glossary = [GlossaryItem]()
        while !items.isAtEnd {
            do {
                let item = try items.decode(String.self)
                glossary.append(.text(item))
            } catch {
                let item = try items.nestedContainer(keyedBy: GlossaryKeys.self)
                let type = try item.decode(String.self, forKey: .type)
                switch type {
                case "text":
                    let text = try item.decode(String.self, forKey: .text)
                    glossary.append(.text(text))
                case "image":
                    let path = try item.decode(String.self, forKey: .path)
                    let width = try? item.decode(Int.self, forKey: .width)
                    let height = try? item.decode(Int.self, forKey: .height)
                    let title = try? item.decode(String.self, forKey: .title)
                    let description = try? item.decode(String.self, forKey: .description)
                    let pixelated = try? item.decode(Bool.self, forKey: .pixelated)

                    glossary.append(.image(path: path, width: width, height: height, title: title, description: description, pixelated: pixelated ?? false))
                default: break
                }
            }
        }
        self.glossary = glossary
        sequence = try values.decode(Int.self)
        termTags = try values.decode(String.self)
    }
}
