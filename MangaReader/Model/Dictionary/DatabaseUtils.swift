//
//  DatabaseUtils.swift
//  Kantan-Manga
//
//  Created by Juan on 17/01/21.
//

import Foundation

struct DatabaseUtils {
    static func resetToInitialDatabase(initialPath: URL, fileName: String = "dic.db", fileManager: FileManager = .default, completion: (() -> Void)? = nil) {
        guard let libraryUrl = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            completion?()
            return
        }
        let libraryDbUrl = libraryUrl.appendingPathComponent(fileName)

        DispatchQueue.global(qos: .utility).async {
            do {
                if fileManager.fileExists(atPath: libraryDbUrl.path) {
                    try fileManager.removeItem(at: libraryDbUrl)
                }
                try FileManager.default.copyItem(at: initialPath, to: libraryDbUrl)
                completion?()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
