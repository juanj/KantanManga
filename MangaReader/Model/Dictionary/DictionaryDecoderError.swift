//
//  DictionaryDecoderError.swift
//  Kantan-Manga
//
//  Created by Juan on 27/11/20.
//

import Foundation

enum DictionaryDecoderError: Error {
    case canNotReadFile
    case indexNotFound
    case decodeCancelled
}
