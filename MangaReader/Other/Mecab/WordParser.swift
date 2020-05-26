//
//  WordParser.swift
//  MangaReader
//
//  Created by Juan on 25/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

// swiftlint:disable cyclomatic_complexity function_body_length
// TODO: Find a way to simplify this

// Code ported from Kimtaro / ve
// https://github.com/Kimtaro/ve
class WordPaser {
    enum PartOfSpeech {
        case noun, properNoun, pronoun, adjective, adverb, determiner, preposition, postposition, verb, suffix, preffix, conjunction, interjection, number, symbol, other, tdb
    }

    enum Grammar {
        case auxillary, nominal
    }

    struct Word {
        var tokens = [Token]()
        var word = ""
        var partOfSpeech: PartOfSpeech?
    }

    class func parse( tokens: [Token]) -> [Word] {
        var tokens = tokens
        var words = [Word]()
        var previos: Token?

        while tokens.first != nil {
            let token = tokens.removeFirst()
            var pos: PartOfSpeech?
            var grammar: Grammar?
            var eatNext = false
            var eatLemma = true
            var attachToPrevious = false
            var alsoAttachToLemma = false
            var updatePos = false

            switch token.partOfSpeech {
            case .meishi:
                pos = .noun

                switch token.partsOfSpeech[1] {
                case .koyuumeishi:
                    pos = .properNoun
                case .daimeishi:
                    pos = .pronoun
                case .fukushikanou, .sahensetsuzoku, .keiyoudoushigokan, .naikeiyoushigokan:
                    if tokens.count > 1 {
                        let following = tokens[0]
                        if following.inflectionType == .sahenSuru {
                            pos = .verb
                            eatNext = true
                        } else if following.inflectionType == .tokushuDa {
                            pos = .adjective
                            if following.inflectionForm == .taigensetsuzoku {
                                eatNext = true
                                eatLemma = false
                            }
                        } else if following.inflectionType == .tokushuNai {
                            pos = .adjective
                            eatNext = true
                        } else if following.partOfSpeech == .joshi && following.surface == "に" {
                            pos = .adverb
                            eatNext = false
                        }
                    }
                case .hijiritsu, .tokushu:
                    if tokens.count > 1 {
                        let following = tokens[0]
                        switch token.partsOfSpeech[2] {
                        case .fukushikanou:
                            if following.partOfSpeech == .joshi && following.surface == "に" {
                                pos = .adverb
                                eatNext = true
                            }
                        case .jodoushigokan:
                            if following.inflectionType == .tokushuDa {
                                pos = .verb
                                grammar = .auxillary
                                if following.inflectionForm == .taigensetsuzoku {
                                    eatNext = true
                                }
                            } else if following.partOfSpeech == .joshi && following.partsOfSpeech[1] == .fukushika {
                                pos = .adverb
                                eatNext = true
                            }
                        case .keiyoudoushigokan:
                            pos = .adjective
                            if (following.inflectionType == .tokushuDa && following.inflectionForm == .taigensetsuzoku) ||
                                following.partsOfSpeech[1] == .rentaika {
                                eatNext = true
                            }
                        default:
                            break
                        }
                    }
                case .kazu:
                    pos = .number
                    if words.last?.partOfSpeech == .number {
                        attachToPrevious = true
                        alsoAttachToLemma = true
                    }
                case .setsubi:
                    if token.partsOfSpeech[2] == .jinmei {
                        pos = .suffix
                    } else {
                        if token.partsOfSpeech[2] == .tokushu && token.originalForm == "さ" {
                            updatePos = true
                            pos = .noun
                        } else {
                            alsoAttachToLemma = true
                        }
                        attachToPrevious = true
                    }
                case .setsuzokushiteki:
                    pos = .conjunction
                case .doushihijiritsuteki:
                    pos = .verb
                    grammar = .nominal
                default:
                    break
                }
            case .settoushi:
                pos = .preffix
            case .jodoushi:
                pos = .postposition

                let inflections: [Token.InflectionType] = [.tokushuTa, .tokushuNai, .tokushuTai, .tokushuMasu, .tokushuNu]
                if let inflectionType = token.inflectionType, (previos == nil || (previos!.partsOfSpeech.count > 1 && previos?.partsOfSpeech[1] != .kakarijoshi)) && inflections.contains(inflectionType) {
                    attachToPrevious = true
                } else if token.inflectionType == .fuhenkagata && token.originalForm == "ん" {
                    attachToPrevious = true
                } else if (token.inflectionType == .tokushuDa || token.inflectionType == .tokushuDesu) && token.surface != "な" {
                    pos = .verb
                }
            case .doushi:
                pos = .verb

                if token.partsOfSpeech[1] == .setsubi {
                    attachToPrevious = true
                } else if token.partsOfSpeech[1] == .hijiritsu && token.inflectionForm != .meireiI {
                    attachToPrevious = true
                }
            case .keiyoushi:
                pos = .adjective
            case .joshi:
                pos = .postposition

                let literals = ["て", "で", "ば"]
                if token.partsOfSpeech[1] == .setsuzokujoshi && literals.contains(token.surface) {
                    attachToPrevious = true
                }
            case .rentaishi:
                pos = .determiner
            case .setsuzokushi:
                pos = .conjunction
            case .fukushi:
                pos = .adverb
            case .kigou:
                pos = .symbol
            case .firaa, .kandoushi:
                pos = .interjection
            case .sonota:
                pos = .other
            default:
                break
            }

            if attachToPrevious && words.count > 0 {
                words[words.count - 1].tokens.append(token)
                words[words.count - 1].word += token.surface
                if updatePos {
                    words[words.count - 1].partOfSpeech = pos
                }
            } else {
                if pos == nil {
                    pos = .tdb
                }
                var word = Word(tokens: [token], word: token.surface, partOfSpeech: pos)

                if eatNext {
                    let following = tokens.removeFirst()
                    word.tokens.append(following)
                    word.word += following.surface
                }

                words.append(word)
            }
            previos = token
        }
        return words
    }
}
