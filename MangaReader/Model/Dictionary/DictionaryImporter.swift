//
//  DictionaryImporter.swift
//  Kantan-Manga
//
//  Created by Juan on 27/11/20.
//

import Foundation
import SQLite
import ZIPFoundation

struct DictionaryImporter {
    let connection : Connection
    func importDictionary(path: URL) throws {
        guard let zipFile = Archive(url: path, accessMode: .read) else {
            throw DictionaryImporterError.canNotReadFile
        }

        let index = try importIndex(zip: zipFile)
        // TODO: Check if dictionary already exists
    }

    func importIndex(zip: Archive) throws -> DictionaryIndex {
        guard let indexFile = zip["index.json"] else {
            throw DictionaryImporterError.indexNotFound
        }

        var data = Data()
        _ = try zip.extract(indexFile) { partData in
            data.append(partData)
        }

        let decoder = JSONDecoder()
        let index = try decoder.decode(DictionaryIndex.self, from: data)
        return index
    }
}
