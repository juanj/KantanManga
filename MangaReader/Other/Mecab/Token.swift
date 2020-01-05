//
//  Token.swift
//  mecab-ios-sample
//
//  Created by Landon Epps on 4/8/19.
//  Copyright © 2019 Landon Epps. All rights reserved.
//

import mecab

/**
 A struct that represents a mecab node.
 
 nil is used instead of "*" (MeCab's convention) to represent a non-exsistent feature
 */
struct Token {
    /// the exact substring for the token from the text (表層形)
    let surface: String
    /// the primary part of speech (品詞)
    let partOfSpeech: String?
    /// an array including the primary part of speech and any subtypes (品詞, 品詞細分類1, ...)
    let partsOfSpeech: [String]
    /// the inflection of the word (活用形)
    let inflection: String?
    /// the type of inflection (活用型)
    let inflectionType: String?
    /// the deinflected form (原形)
    let originalForm: String?
    /// the reading of the word (読み)
    let reading: String?
    /// the pronunciation of the word (発音)
    let pronunciation: String?

    init?(with node: mecab_node_t) {
        guard let surface = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: node.surface), length: Int(node.length), encoding: .utf8, freeWhenDone: false),
            let feature = node.feature,
            let features = String(cString: feature, encoding: .utf8)?.components(separatedBy: ",") else {
                // if we don't have a surface and feature, we can't create a mecab nodeString.Encoding.utf8.rawValue
                return nil
        }

        self.surface = surface as String

        if features.count > 0 {
            partOfSpeech = features[0] != "*" ? features[0] : nil
        } else {
            partOfSpeech = nil
        }

        var partsOfSpeech = [String]()
        if features.count > 3 {
            for index in 0...3 where features[index] != "*" {
                partsOfSpeech.append(features[index])
            }
        }
        self.partsOfSpeech = partsOfSpeech

        if features.count > 4 {
            inflection = features[4] != "*" ? features[4] : nil
        } else {
            inflection = nil
        }

        if features.count > 5 {
            inflectionType = features[5] != "*" ? features[5] : nil
        } else {
            inflectionType = nil
        }

        if features.count > 6 {
            originalForm = features[6] != "*" ? features[6] : nil
        } else {
            originalForm = nil
        }

        if features.count > 7 {
            reading = features[7] != "*" ? features[7] : nil
        } else {
            reading = nil
        }

        if features.count > 8 {
            pronunciation = features[8] != "*" ? features[8] : nil
        } else {
            pronunciation = nil
        }
    }
}
