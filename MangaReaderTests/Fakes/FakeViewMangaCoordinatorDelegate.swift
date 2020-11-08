//
//  FakeViewMangaCoordinatorDelegate.swift
//  MangaReaderTests
//
//  Created by Juan on 31/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class FakeViewMangaCoordinatorDelegate: ViewMangaCoordinatorDelegate {
    var didEndCalled = false
    func didEnd(_ viewMangaCoordinator: ViewMangaCoordinator) {
        didEndCalled = true
    }
}
