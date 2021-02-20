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

    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void) {
        tesseract.pageSegmentationMode = .singleBlockVerticalText
        DispatchQueue.global(qos: .utility).async {
            let result: Result<String, Tesseract.Error> = self.tesseract.performOCR(on: image)
            switch result {
            case .success(let text):
                let cleanText = self.cleanOutput(text)
                completion(.success(cleanText))
            case .failure:
                completion(.failure(TesseractError.recognitionError))
            }
        }
    }

    private func cleanOutput(_ output: String) -> String {
        var notAllowed = CharacterSet.decimalDigits // Remove numbers
        notAllowed.formUnion(CharacterSet("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ".unicodeScalars)) // And latin characters
        notAllowed.formUnion(CharacterSet(#"-_/\()|〔〕[]{}%:<>"#.unicodeScalars)) // Some symbols
        let cleanUnicodeScalars = output.replacingOccurrences(of: "\n", with: "  ") // Make text one line
            .trimmingCharacters(in: .whitespacesAndNewlines) // Remove extra padding
            .unicodeScalars
            .filter { !notAllowed.contains($0) }
        return String(cleanUnicodeScalars)
    }
}
