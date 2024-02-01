//
//  Reader.swift
//  MangaReader
//
//  Created by Juan on 26/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

protocol Reader {
    typealias Completion = (Data?) -> Void

    var numberOfPages: Int { get }
    init(fileName: String) throws
    func readEntityAt(index: Int, _ completion: Completion?)
}

extension Reader {
    private func readFirstImageEntry(startingIndex: Int, _ completion: @escaping Completion) {
        readEntityAt(index: startingIndex) { (data) -> Void in
            if let data = data, UIImage(data: data) != nil {
                completion(data)
            } else if startingIndex < numberOfPages - 1 {
                readFirstImageEntry(startingIndex: startingIndex + 1, completion)
            } else {
                completion(nil)
            }
        }
    }

    func readFirstImageEntry(_ completion: @escaping Completion) {
        readFirstImageEntry(startingIndex: 0, completion)
    }
}
