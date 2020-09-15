//
//  MockAddMangasCoordinatorDelegate.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class MockAddMangasCoordinatorDelegate: AddMangasCoordinatorDelegate {
    var didEndCalled = false
    var cancelCalled = false
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator) {
        didEndCalled = true
    }

    func cancel(_ addMangasCoordinator: AddMangasCoordinator) {
        cancelCalled = true
    }


}
