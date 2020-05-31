//
//  MockViewMangaCoordinatorDelegate.swift
//  MangaReaderTests
//
//  Created by Juan on 31/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import MangaReader

class MockViewMangaCoordinatorDelegate: ViewMangaCoordinatorDelegate {
    var didEndCalled = false
    func didEnd(viewMangaCoordinator: ViewMangaCoordinator) {
        didEndCalled = true
    }
}
