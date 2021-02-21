//
//  FakeCreateAnkiCardCoordinatorDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

@testable import Kantan_Manga

class FakeCreateAnkiCardCoordinatorDelegate: CreateAnkiCardCoordinatorDelegate {
    var didEndCalled = false
    func didEnd(_ createAnkiCardCoordinator: CreateAnkiCardCoordinator) {
        didEndCalled = true
    }
}
