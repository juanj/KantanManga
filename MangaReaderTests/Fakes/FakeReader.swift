//
//  FakeReader.swift
//  Kantan-MangaTests
//
//  Created by Juan on 16/11/20.
//

@testable import Kantan_Manga

class FakeReader: Reader {
    let fileName: String
    var readEntries = [Int]()
    var numberOfPages = 0

    required init(fileName: String) {
        self.fileName = fileName
    }

    func readEntityAt(index: Int, _ callBack: CallBack?) {
        readEntries.append(index)
        callBack?(UIImage(systemName: "0.circle.fill")?.pngData())
    }
}
