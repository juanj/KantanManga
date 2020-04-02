//
//  FuriganaUtils.swift
//  MangaReader
//
//  Created by Juan on 7/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

func unicodeScalatToString(_ scalar: String.UnicodeScalarView.Element) -> String {
    var string = ""
    string.unicodeScalars.append(scalar)
    return string
}

func getFurigana(token: Token) -> [Furigana] {
    var furigana = [Furigana]()
    var parts = [(String, String)]()

    var pattern = ""
    var numberOfGroupos = 1
    var isLastTokenKanji = false
    var substrings = [String]()

    for character in token.surface.unicodeScalars {
        if character.properties.isIdeographic {
            if !isLastTokenKanji {
                isLastTokenKanji = true
                pattern += "(.*)"
                numberOfGroupos += 1
                substrings.append(unicodeScalatToString(character))
            } else {
                substrings[substrings.count - 1].unicodeScalars.append(character)
            }
        } else {
            isLastTokenKanji = false
            substrings.append(unicodeScalatToString(character))
            pattern += unicodeScalatToString(character).applyingTransform(.hiraganaToKatakana, reverse: true) ?? unicodeScalatToString(character)
        }
    }
    guard let regex = try? NSRegularExpression(pattern: "^\(pattern)$", options: []), let reading = token.reading?.applyingTransform(.hiraganaToKatakana, reverse: true) else {
        return furigana
    }
    let nsrange = NSRange(reading.startIndex..<reading.endIndex, in: reading)
    regex.enumerateMatches(in: reading, options: [], range: nsrange) { (match, _, stop) in
        guard let match = match else { return }
        if match.numberOfRanges == numberOfGroupos {
            var pickKanji = 1
            for substring in substrings {
                if substring.unicodeScalars.first?.properties.isIdeographic ?? false {
                    guard let range = Range(match.range(at: pickKanji), in: reading) else { return }
                    parts.append((substring, String(reading[range])))
                    pickKanji += 1
                } else {
                    parts.append((substring, substring))
                }
            }
            stop.pointee = true
        }
    }
    var position = 0
    for part in parts {
        if part.0.unicodeScalars.first!.properties.isIdeographic {
            furigana.append(Furigana(kana: part.1, range: NSRange(location: position, length: part.0.count)))
        }
        position += part.0.count
    }

    return furigana
}
