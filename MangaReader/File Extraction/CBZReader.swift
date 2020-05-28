//
//  CBZReader.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import ZIPFoundation

enum CBZReaderError: Error {
    case invalidFilePath
    case errorCreatingArchive
}

class CBZReader: Reader {
    public var numberOfPages: Int {
        return fileEntries.count
    }

    private var fileName = ""
    private var fileEntries = [Entry]()
    private let filePath: URL

    required init(fileName: String) throws {
        self.fileName = fileName
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        filePath = documentsDirectory.appendingPathComponent(fileName)
        try loadEntries()
    }

    private func loadEntries() throws {
        guard let archive = Archive(url: filePath, accessMode: .read) else {
            throw CBZReaderError.errorCreatingArchive
        }
        for entry in archive.makeIterator() where entry.type == .file {
            fileEntries.append(entry)
        }
    }

    func readEntityAt(index: Int, _ callBack: Reader.CallBack?) {
        guard index >= 0 && index < fileEntries.count else {
            callBack?(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let entry = self.fileEntries[index]
            do {
                var entryData = Data()
                guard let archive = Archive(url: self.filePath, accessMode: .read) else {
                    callBack?(nil)
                    return
                }
                _ = try archive.extract(entry) { (data) in
                    entryData.append(data)
                }
                callBack?(entryData)
            } catch {
                callBack?(nil)
            }
        }
    }
}
