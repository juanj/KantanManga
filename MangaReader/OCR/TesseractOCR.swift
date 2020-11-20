//
//  TesseractOCR.swift
//  MangaReader
//
//  Created by DevBakura on 23/05/20.
//  Copyright © 2020 Juan. All rights reserved.
//

import Foundation
import SwiftyTesseract

class TesseractOCR: ImageOCR {
    enum TesseractError: Error {
        case recognitionError
    }

    private let tesseract = Tesseract(language: .custom("jpn_vert"))

    func recognize(image: UIImage, _ callback: @escaping (Result<String, Error>) -> Void) {
        tesseract.pageSegmentationMode = .singleBlockVerticalText
        DispatchQueue.global(qos: .utility).async {
            let result: Result<String, Tesseract.Error> = self.tesseract.performOCR(on: image)
            switch result {
            case .success(let text):
                let cleanText = text.replacingOccurrences(of: "\n", with: "  ").trimmingCharacters(in: .whitespacesAndNewlines)
                callback(.success(cleanText))
            case .failure:
                callback(.failure(TesseractError.recognitionError))
            }
        }
    }

}
