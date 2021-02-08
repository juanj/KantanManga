//
//  GoogleVisionOCR.swift
//  MangaReader
//
//  Created by DevBakura on 23/05/20.
//  Copyright © 2020 Juan. All rights reserved.
//

import Foundation
import Firebase

class GoogleVistionOCR: ImageOCR {
    private let vision = Vision.vision()
    private let options: VisionCloudTextRecognizerOptions = {
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["ja"]
        return options
    }()

    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void) {
        let textRecognizer = vision.cloudTextRecognizer(options: options)
        let visionImage = VisionImage(image: image)
        textRecognizer.process(visionImage) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let result = result else { return }

            let text = result.text.replacingOccurrences(of: "\n", with: " ")
            completion(.success(text))
        }
    }
}
