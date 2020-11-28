//
//  TermMetaEntry.swift
//  Kantan-Manga
//
//  Created by Juan on 28/11/20.
//

import Foundation

struct TermMetaEntry {
    enum Mode {
        case freq, pitch
    }
    let character: String
    let mode: Mode
    let data: String // TODO: implement "freq/pitch" objects
}
