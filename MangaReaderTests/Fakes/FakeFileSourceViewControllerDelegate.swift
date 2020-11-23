//
//  FakeFileSourceViewControllerDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 22/11/20.
//

@testable import Kantan_Manga

class FakeFileSourceViewControllerDelegate: FileSourceViewControllerDelegate {
    func openWebServer(_ fileSourceViewController: FileSourceViewController) {}
    func openLocalFiles(_ fileSourceViewController: FileSourceViewController) {}
}
