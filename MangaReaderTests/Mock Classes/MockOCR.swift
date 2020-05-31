//
//  MockOCR.swift
//  MangaReaderTests
//
//  Created by Juan on 31/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import MangaReader

class MockOCR: ImageOCR {
    var image: UIImage?
    func recognize(image: UIImage, _ callback: @escaping (Result<String, Error>) -> Void) {
        self.image = image
    }
}
