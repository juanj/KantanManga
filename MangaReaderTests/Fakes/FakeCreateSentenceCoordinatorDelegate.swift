//
//  FakeCreateSentenceCoordinatorDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

@testable import Kantan_Manga

class FakeCreateSentenceCoordinatorDelegate: CreateSentenceCoordinatorDelegate {
    var didEndCalled = false
    func didEnd(_ createSentenceCoordinator: CreateSentenceCoordinator) {
        didEndCalled = true
    }
}
