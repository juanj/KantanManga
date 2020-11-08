//
//  FakeImageOCR.swift
//  Kantan-MangaTests
//
//  Created by Juan on 8/11/20.
//

@testable import Kantan_Manga

class FakeImageOcr: ImageOCR {
    func recognize(image: UIImage, _ callback: @escaping (Result<String, Error>) -> Void) {}
}
