//
//  FakeCreateSentenceViewControllerDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

import Foundation

@testable import Kantan_Manga

class FakeCreateSentenceViewControllerDelegate: CreateSentenceViewControllerDelegate {
    var cancelCalled = false
    var saveCalled = false
    var editImageCalled = false
    func cancel(_ createSentenceViewController: CreateSentenceViewController) {
        cancelCalled = true
    }

    func save(_ createSentenceViewController: CreateSentenceViewController, word: String, reading: String, sentence: String, definition: String) {
        saveCalled = true
    }

    func editImage(_ createSentenceViewController: CreateSentenceViewController) {
        editImageCalled = true
    }
}
