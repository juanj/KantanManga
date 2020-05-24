//
//  TesseractOCR.swift
//  MangaReader
//
//  Created by DevBakura on 23/05/20.
//  Copyright © 2020 Juan. All rights reserved.
//

import Foundation
import TesseractOCR

class TesseractOCR: ImageOCR {
    enum TesseractError: Error {
        case recognitionError
    }

    private let tesseract = G8Tesseract(language: "jpn_vert")

    func recognize(image: UIImage, _ callback: @escaping (Result<String, Error>) -> Void) {
        if let tesseract = tesseract {
            tesseract.engineMode = .lstmOnly
            tesseract.pageSegmentationMode = .singleBlockVertText
            tesseract.image = image
            DispatchQueue.global(qos: .utility).async {
                tesseract.recognize()
                if let text = tesseract.recognizedText {
                    let cleanText = text.replacingOccurrences(of: "\n", with: "  ").trimmingCharacters(in: .whitespacesAndNewlines)
                    callback(.success(cleanText))
                } else {
                    callback(.failure(TesseractError.recognitionError))
                }
            }
        }
    }

}
