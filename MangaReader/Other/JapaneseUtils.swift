//
//  JapaneseUtils.swift
//  MangaReader
//
//  Created by Juan on 7/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

class JapaneseUtils {
    private struct Prematch {
        let pattern: String
        let numberOfGroups: Int
        let substrings: [String]
    }

    static func unicodeScalatToString(_ scalar: String.UnicodeScalarView.Element) -> String {
        var string = ""
        string.unicodeScalars.append(scalar)
        return string
    }

    static func getFurigana(text: String, reading: String?) -> [Furigana] {
        let preMatch = getPrematch(text: text)

        guard let regex = try? NSRegularExpression(pattern: "^\(preMatch.pattern)$"),
              let reading = reading?.applyingTransform(.hiraganaToKatakana, reverse: true) else {
            return []
        }

        var furigana = [Furigana]()
        let fullReadingRange = NSRange(reading.startIndex..<reading.endIndex, in: reading)
        regex.enumerateMatches(in: reading, range: fullReadingRange) { (match, _, stop) in
            guard let match = match, match.numberOfRanges == preMatch.numberOfGroups else { return }
            var pickKanji = 1
            var position = 0
            for substring in preMatch.substrings {
                if substring.unicodeScalars.first?.properties.isIdeographic == true {
                    guard let range = Range(match.range(at: pickKanji), in: reading) else { return }
                    furigana.append(Furigana(kana: String(reading[range]), range: NSRange(location: position, length: substring.count)))
                    pickKanji += 1
                }
                position += substring.count
            }
            stop.pointee = true
        }

        return furigana
    }

    private static func getPrematch(text: String) -> Prematch {
        var pattern = ""
        var numberOfGroups = 1
        var isLastTokenKanji = false
        var substrings = [String]()
        for character in text.unicodeScalars {
            if character.properties.isIdeographic {
                if !isLastTokenKanji {
                    isLastTokenKanji = true
                    pattern += "(.*)"
                    numberOfGroups += 1
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

        return Prematch(pattern: pattern, numberOfGroups: numberOfGroups, substrings: substrings)
    }

    static func splitKanji(word: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: #"\p{han}"#) else { return [] }
        let results = regex.matches(in: word,
                                    range: NSRange(word.startIndex..., in: word))
        let kanji =  results.compactMap { match -> String? in
            guard let range = Range(match.range, in: word) else { return nil }
            return String(word[range])
        }
        return kanji
    }
}
