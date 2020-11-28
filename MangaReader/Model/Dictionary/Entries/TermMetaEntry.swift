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

    struct PitchAccent {
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
