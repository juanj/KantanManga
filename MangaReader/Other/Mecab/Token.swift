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
    enum PartOfSpeech: String {
        case meishi = "名詞"
        case koyuumeishi = "固有名詞"
        case daimeishi = "代名詞"
        case jodoushi = "助動詞"
        case kazu = "数"
        case joshi = "助詞"
        case settoushi = "接頭詞"
        case doushi = "動詞"
        case kigou = "記号"
        case firaa = "フィラー"
        case sonota = "その他"
        case kandoushi = "感動詞"
        case rentaishi = "連体詞"
        case setsuzokushi = "接続詞"
        case fukushi = "副詞"
        case setsuzokujoshi = "接続助詞"
        case keiyoushi = "形容詞"
        case hijiritsu = "非自立"
        case fukushikanou = "副詞可能"
        case sahensetsuzoku = "サ変接続"
        case keiyoudoushigokan = "形容動詞語幹"
        case naikeiyoushigokan = "ナイ形容詞語幹"
        case jodoushigokan = "助動詞語幹"
        case fukushika = "副詞化"
        case rentaika = "連体化"
        case tokushu = "特殊"
        case setsubi = "接尾"
        case setsuzokushiteki = "接続詞的"
        case doushihijiritsuteki = "動詞非自立的"
        case jinmei = "人名"
        case kakarijoshi = "係助詞"
        case other

        init(value: String) {
            self = PartOfSpeech(rawValue: value) ?? .other
        }
    }

    enum InflectionType: String {
        case sahenSuru = "サ変・スル"
        case tokushuTa = "特殊・タ"
        case tokushuNai = "特殊・ナイ"
        case tokushuTai = "特殊・タイ"
        case tokushuDesu = "特殊・デス"
        case tokushuDa = "特殊・ダ"
        case tokushuMasu = "特殊・マス"
        case tokushuNu = "特殊・ヌ"
        case fuhenkagata = "不変化型"
        case other = ""

        init(value: String) {
            self = InflectionType(rawValue: value) ?? .other
        }
    }

    enum InflectionForm: String {
        case taigensetsuzoku = "体言接続"
        case meireiI = "命令ｉ"
        case other = ""

        init(value: String) {
            self = InflectionForm(rawValue: value) ?? .other
        }
    }

    /// the exact substring for the token from the text (表層形)
    let surface: String
    /// the primary part of speech (品詞)
    let partOfSpeech: PartOfSpeech?
    /// an array including the primary part of speech and any subtypes (品詞, 品詞細分類1, ...)
    let partsOfSpeech: [PartOfSpeech]
    /// the inflection of the word (活用形)
    let inflectionType: InflectionType?
    /// the type of inflection (活用型)
    let inflectionForm: InflectionForm?
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
            partOfSpeech = features[0] != "*" ? PartOfSpeech(value: features[0]) : nil
        } else {
            partOfSpeech = nil
        }

        var partsOfSpeech = [PartOfSpeech]()
        if features.count > 3 {
            for index in 0...3 where features[index] != "*" {
                partsOfSpeech.append(PartOfSpeech(value: features[index]))
            }
        }
        self.partsOfSpeech = partsOfSpeech

        if features.count > 4 {
            inflectionType = features[4] != "*" ? InflectionType(value: features[4]) : nil
        } else {
            inflectionType = nil
        }

        if features.count > 5 {
            inflectionForm = features[5] != "*" ? InflectionForm(value: features[5]) : nil
        } else {
            inflectionForm = nil
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
