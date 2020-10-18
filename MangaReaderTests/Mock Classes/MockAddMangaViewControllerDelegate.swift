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

    func cancel(_ addMangaViewController: AddMangaViewController) {
        cancelCalled = true
    }

    func save(_ addMangaViewController: AddMangaViewController, name: String?) {
        saveCalled = true
    }

    func selectManga(_ addMangaViewController: AddMangaViewController) {
        selectMangaCalled = true
    }

    func selectCollection(_ addMangaViewController: AddMangaViewController) {
        selectCollectionCalled = true
    }
}
