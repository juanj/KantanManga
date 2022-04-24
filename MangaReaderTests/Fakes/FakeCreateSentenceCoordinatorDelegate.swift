//
//  FakeEditSentenceCoordinatorDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

@testable import Kantan_Manga

class FakeEditSentenceCoordinatorDelegate: EditSentenceCoordinatorDelegate {


    var didCancelCalled = false
    var didEndCalled = false
    func didCancel(_ createSentenceCoordinator: EditSentenceCoordinator) {
        didCancelCalled = true
    }

    func didEnd(_ createSentenceCoordinator: EditSentenceCoordinator, image: UIImage?, word: String, reading: String, sentence: String, definition: String) {
        didEndCalled = true
    }
}
