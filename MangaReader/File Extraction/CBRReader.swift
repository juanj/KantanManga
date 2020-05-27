//
//  CBRReader.swift
//  MangaReader
//
//  Created by Juan on 26/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation
import UnrarKit

class CBRReader: Reader {
    public var numberOfPages: Int {
        return fileEntries.count
    }

    private var fileName = ""
    private var fileEntries = [String]()
    private var cache = [Int: Data]()
    private let filePath: URL

    required init(fileName: String) throws {
        self.fileName = fileName
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        filePath = documentsDirectory.appendingPathComponent(fileName)

        try loadEntries()
    }

    private func loadEntries() throws {
        let archive = try URKArchive(url: filePath)
        fileEntries = try archive.listFilenames()
    }

    func readFirstEntry(_ callBack: @escaping Reader.CallBack) {
        readEntityAt(index: 0, callBack)
    }

    func readEntityAt(index: Int, _ callBack: Reader.CallBack?) {
        guard index >= 0 && index < fileEntries.count else {
            callBack?(nil)
            return
        }

        if let entry = cache[index] {
            callBack?(entry)
            return
        }

        let entry = fileEntries[index]
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let archive = try URKArchive(url: self.filePath)
                let data = try archive.extractData(fromFile: entry)
                self.cache[index] = data
                callBack?(data)
            } catch {
                callBack?(nil)
            }
        }
    }
}
