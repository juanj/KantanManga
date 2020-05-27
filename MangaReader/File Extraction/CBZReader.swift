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
    private var observers = [Int: NSKeyValueObservation]()
    private var progresses = [Int: Progress]()
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
        guard let archive = Archive(url: filePath, accessMode: .read) else {
            throw CBZReaderError.errorCreatingArchive
        }
        for entry in archive.makeIterator() where entry.type == .file {
            fileEntries.append(entry)
        }
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

        var tempData = Data()
        let progress = Progress()
        progresses[index] = progress
        observers[index] = progress.observe(\.fractionCompleted, changeHandler: { (progress, _) in
            if progress.fractionCompleted == 1 {
                callBack?(tempData)
                self.cache[index] = tempData
                self.progresses.removeValue(forKey: index)
                self.observers.removeValue(forKey: index)
            }
        })
        let entry = fileEntries[index]
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let archive = Archive(url: self.filePath, accessMode: .read) else {
                    callBack?(nil)
                    return
                }
                _ = try archive.extract(entry, bufferSize: UInt32(16*1024), progress: progress, consumer: { (aData) in
                    tempData.append(aData)
                })
            } catch {
                callBack?(nil)
            }
        }
    }
}
