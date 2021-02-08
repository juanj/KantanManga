//
//  FakeImageOCR.swift
//  Kantan-MangaTests
//
//  Created by Juan on 8/11/20.
//

@testable import Kantan_Manga

class FakeImageOcr: ImageOCR {
    var recognizeCalls = [UIImage]()
    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void) {
        recognizeCalls.append(image)
        completion(.success("Test"))
    }
}
