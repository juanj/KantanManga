//
//  FakeCompoundDictionary.swift
//  Kantan-MangaTests
//
//  Created by Juan on 6/12/20.
//

@testable import Kantan_Manga

class FakeCompoundDictionary: CompoundDictionary {
    override func connectToDataBase(fileName: String = "dic.db", fileManager: FileManager = .default) throws {}
    override func createDataBase(fileName: String = "dic.db", fileManager: FileManager = .default) throws {}
    override func addDictionary(_ dictionary: Dictionary) throws {}
}
