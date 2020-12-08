//
//  TermMetaEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct TermMetaEntry {
    struct PitchAccent: Codable {
        let position: Int
        let tags: [String]?
    }

    enum Mode {
        case freq(frequency: Int, reading: String? = nil)
        case pitch(reading: String, pitches: [PitchAccent])
    }

    let character: String
    let mode: Mode
}

extension TermMetaEntry.Mode: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, frequency, reading, pitches
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        switch type {
        case "freq":
            let frequency = try values.decode(Int.self, forKey: .frequency)
            let reading = try? values.decode(String.self, forKey: .reading)
            self = .freq(frequency: frequency, reading: reading)
        case "pitch":
            let reading = try values.decode(String.self, forKey: .reading)
            let pitches = try values.decode([TermMetaEntry.PitchAccent].self, forKey: .pitches)
            self = .pitch(reading: reading, pitches: pitches)
        default:
            self = .freq(frequency: 0)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .freq(let frquency, let reading):
            try container.encode("freq", forKey: .type)
            try container.encode(frquency, forKey: .frequency)
            try container.encodeIfPresent(reading, forKey: .reading)
        case .pitch(let reading, let pitches):
            try container.encode("pitch", forKey: .type)
            try container.encode(reading, forKey: .reading)
            try container.encode(pitches, forKey: .pitches)
        }
    }
}

extension TermMetaEntry: CustomStringConvertible {
    var description: String {
        return "\(character), \(mode)"
    }
}

extension TermMetaEntry: Decodable {
    private enum FreqKeys: String, CodingKey {
        case reading, frequency
    }

    private enum PitchKeys: String, CodingKey {
        case reading, pitches
    }

    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        character = try values.decode(String.self)

        let type = try values.decode(String.self)
        switch type {
        case "freq":
            do {
                // If Int or String
                var frequency: Int
                if let freq = try? values.decode(Int.self) {
                    frequency = freq
                } else {
                    let frequencyString = try values.decode(String.self)
                    frequency = Int(frequencyString) ?? 0
                }
                mode = .freq(frequency: frequency, reading: nil)
            } catch {
                // If Object
                let item = try values.nestedContainer(keyedBy: FreqKeys.self)

                var frequency: Int
                if let freq = try? item.decode(Int.self, forKey: .frequency) {
                    frequency = freq
                } else {
                    let frequencyString = try item.decode(String.self, forKey: .frequency)
                    frequency = Int(frequencyString) ?? 0
                }

                let reading = try item.decode(String.self, forKey: .reading)
                mode = .freq(frequency: frequency, reading: reading)
            }
        case "pitch":
            let item = try values.nestedContainer(keyedBy: PitchKeys.self)
            let reading = try item.decode(String.self, forKey: .reading)
            let pitches = try item.decode([PitchAccent].self, forKey: .pitches)

            mode = .pitch(reading: reading, pitches: pitches)
        default:
            mode = .freq(frequency: 0, reading: nil)
        }
    }
}
