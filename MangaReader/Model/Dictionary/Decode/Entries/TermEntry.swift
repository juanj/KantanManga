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

extension GlossaryItem: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, text, path, width, height, title, description, pixelated
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let text = try values.decode(String.self, forKey: .text)
            self = .text(text)
        case "image":
            let path = try values.decode(String.self, forKey: .path)
            let width = try? values.decode(Int.self, forKey: .width)
            let height = try? values.decode(Int.self, forKey: .height)
            let title = try? values.decode(String.self, forKey: .title)
            let description = try? values.decode(String.self, forKey: .description)
            let pixelated = (try? values.decode(Bool.self, forKey: .pixelated)) ?? false
            self = .image(path: path, width: width, height: height, title: title, description: description, pixelated: pixelated)
        default:
            self = .text("")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let path, let width, let height, let title, let description, let pixelated):
            try container.encode("image", forKey: .type)
            try container.encode(path, forKey: .path)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
            try container.encode(title, forKey: .title)
            try container.encode(description, forKey: .description)
            try container.encode(pixelated, forKey: .pixelated)
        }
    }
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
