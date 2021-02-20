//
//  TestableMangaViewController.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

@testable import Kantan_Manga

class TestableMangaViewController: MangaViewController {
    override func isValidTap(_ tap: UILongPressGestureRecognizer) -> Bool {
        return true
    }
}
