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
    var filePath = ""
    var archive: Archive
    var fileEntries = [Entry]()
    var observer: NSKeyValueObservation?
    
    init(filePath: String) throws {
        let filePath = URL(fileURLWithPath: filePath)
        guard let archive = Archive(url: filePath, accessMode: .read) else {
            throw CBZReaderError.errorCreatingArhive
        }
        self.archive = archive
        for entry in self.archive.makeIterator() {
            if entry.type == .file {
                self.fileEntries.append(entry)
            }
        }
    }
    
    func readFirstEntry(_ callBack: @escaping (_: Data?) -> Void) {
        let progress = Progress()
        var tempData = Data()
        self.observer = progress.observe(\.fractionCompleted, changeHandler: { (progress, value) in
            if progress.fractionCompleted == 1 {
                callBack(tempData)
            }
        })
        if let entry = self.fileEntries.first {
            do {
                let _ = try archive.extract(entry, bufferSize: UInt32(16*1024), progress: progress, consumer: { (aData) in
                    tempData.append(aData)
                })
            } catch {
                callBack(nil)
            }
        }
    }
}
