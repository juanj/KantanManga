//
//  ImageOCR.swift
//  MangaReader
//
//  Created by DevBakura on 23/05/20.
//  Copyright © 2020 Juan. All rights reserved.
//

import Foundation

protocol ImageOCR {
    func recognize(image: UIImage, _ callback: @escaping (Result<String, Error>) -> Void)
}
