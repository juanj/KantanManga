//
//  DictionaryIndex.swift
//  Kantan-Manga
//
//  Created by Juan on 27/11/20.
//

import Foundation
import GRDB

struct DictionaryIndex: Decodable, Equatable, TableRecord {
    enum Version: Int, Decodable {
        // swiftlint:disable:next identifier_name
        case v1 = 1, v2, v3
    }

    let title: String
    let revision: String
    let sequenced: Bool?
    let format: Version?
    let version: Version?
    let author: String?
    let url: String?
    let description: String?
    let attribution: String?
    // TODO: implement tagMeta

    var fileVersion: Version {
        return version ?? format ?? .v1
    }
}
