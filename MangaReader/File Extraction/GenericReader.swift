//
//  GenericReader.swift
//  Kantan-Manga
//
//  Created by Juan on 8/02/21.
//

import Foundation

enum GenericReaderError: Error {
    case unknownFormat
}

class GenericReader: Reader {
    var numberOfPages: Int {
        reader.numberOfPages
    }

    private let reader: Reader
    required init(fileName: String) throws {
        switch fileName.lowercased().suffix(3) {
        case "cbz", "zip":
            reader = try CBZReader(fileName: fileName)
        case "cbr", "rar":
            reader = try CBRReader(fileName: fileName)
        case "pdf":
            reader = try PDFReader(fileName: fileName)
        default:
            throw GenericReaderError.unknownFormat
        }
    }

    func readEntityAt(index: Int, _ completion: Completion?) {
        reader.readEntityAt(index: index, completion)
    }
}
