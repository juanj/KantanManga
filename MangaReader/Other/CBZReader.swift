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
    case errorCreatingArhive
}

class CBZReader {
    public var numberOfPages: Int {
        return self.fileEntries.count
    }

    private var fileName = ""
    private var fileEntries = [Entry]()
    private var observers = [Int: NSKeyValueObservation]()
    private var progresses = [Int: Progress]()
    private var archives = [Int: Archive]()
    private var cache = [Int: Data]()
    private let filePath: URL

    init(fileName: String) throws {
        self.fileName = fileName
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.filePath = documentsDirectory.appendingPathComponent(fileName)
        try self.loadEntries()
    }

    private func loadEntries() throws {
        guard let archive = Archive(url: self.filePath, accessMode: .read) else {
            throw CBZReaderError.errorCreatingArhive
        }
        for entry in archive.makeIterator() where entry.type == .file {
            self.fileEntries.append(entry)
        }
    }

    func readFirstEntry(_ callBack: @escaping (_: Data?) -> Void) {
        self.readEntityAt(index: 0, callBack)
    }

    func readEntityAt(index: Int, _ callBack: @escaping (_: Data?) -> Void) {
        guard index >= 0 && index < self.fileEntries.count else {
            callBack(nil)
            return
        }

        if let entry = self.cache[index] {
            callBack(entry)
            return
        }

        var tempData = Data()
        let progress = Progress()
        self.progresses[index] = progress
        self.observers[index] = progress.observe(\.fractionCompleted, changeHandler: { (progress, _) in
            if progress.fractionCompleted == 1 {
                callBack(tempData)
                self.cache[index] = tempData
                self.progresses.removeValue(forKey: index)
                self.observers.removeValue(forKey: index)
            }
        })
        let entry = self.fileEntries[index]
        DispatchQueue.global(qos: .background).async {
            do {
                guard let archive = Archive(url: self.filePath, accessMode: .read) else {
                    callBack(nil)
                    return
                }
                _ = try archive.extract(entry, bufferSize: UInt32(16*1024), progress: progress, consumer: { (aData) in
                    tempData.append(aData)
                })
            } catch {
                callBack(nil)
            }
        }
    }
}
