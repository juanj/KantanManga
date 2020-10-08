//
//  MockAddMangaViewControllerDelegate.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class MockAddMangaViewControllerDelegate: AddMangaViewControllerDelegate {
    var cancelCalled = false
    var saveCalled = false
    var selectMangaCalled = false
    var selectCollectionCalled = false

    func cancel(addMangaViewController: AddMangaViewController) {
        cancelCalled = true
    }

    func save(addMangaViewController: AddMangaViewController, name: String?) {
        saveCalled = true
    }

    func selectManga(addMangaViewController: AddMangaViewController) {
        selectMangaCalled = true
    }

    func selectCollection(addMangaViewController: AddMangaViewController) {
        selectCollectionCalled = true
    }
}
