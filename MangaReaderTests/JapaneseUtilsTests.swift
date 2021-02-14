//
//  JapaneseUtilsTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 16/11/20.
//

import XCTest
@testable import Kantan_Manga

class JapaneseUtilsTests: XCTestCase {
    func testGetFurigana_withOneKanji_returnsOneFuriganaWithCorrectRange() {
        let text = "日"
        let reading = "にち"

        let furigana = JapaneseUtils.getFurigana(text: text, reading: reading)

        XCTAssertEqual(furigana, [Furigana(kana: reading, range: NSRange(location: 0, length: 1))])
    }

    func testGetFurigana_withMultipleKanji_returnsOneFuriganaWithCorrectRange() {
        let text = "実験"
        let reading = "じっけん"

        let furigana = JapaneseUtils.getFurigana(text: text, reading: reading)

        XCTAssertEqual(furigana, [Furigana(kana: reading, range: NSRange(location: 0, length: 2))])
    }

    func testGetFurigana_withLeadingKana_returnsFuriganaForKanjiPart() {
        let text = "この人"
        let reading = "このひと"

        let furigana = JapaneseUtils.getFurigana(text: text, reading: reading)

        XCTAssertEqual(furigana, [Furigana(kana: "ひと", range: NSRange(location: 2, length: 1))])
    }

    func testGetFurigana_withTrailingKana_returnsFuriganaForKanjiPart() {
        let text = "配信する"
        let reading = "はいしんする"

        let furigana = JapaneseUtils.getFurigana(text: text, reading: reading)

        XCTAssertEqual(furigana, [Furigana(kana: "はいしん", range: NSRange(location: 0, length: 2))])
    }

    func testGetFurigana_withLongSentence_returnsCorrectFurigana() {
        let text = "この報告は彼の背信を裏付けしている。"
        let reading = "このほうこくはかれのはいしんをうらづけしている。"

        let furigana = JapaneseUtils.getFurigana(text: text, reading: reading)

        XCTAssertEqual(furigana, [
            Furigana(kana: "ほうこく", range: NSRange(location: 2, length: 2)),
            Furigana(kana: "かれ", range: NSRange(location: 5, length: 1)),
            Furigana(kana: "はいしん", range: NSRange(location: 7, length: 2)),
            Furigana(kana: "うらづ", range: NSRange(location: 10, length: 2))
        ])
    }
}
