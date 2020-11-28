//
//  TermMetaEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct TermMetaEntry {
    enum Mode {
        case freq(frequency: Int, reading: String? = nil)
        case pitch(reading: String, pitches: [PitchAccent])
    }

    struct PitchAccent: Decodable {
        let position: Int
        let tags: [String]?
    }

    let character: String
    let mode: Mode
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
