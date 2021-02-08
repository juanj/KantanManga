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
    func readFirstEntry(_ completion: @escaping Completion) {
        readEntityAt(index: 0, completion)
    }
}
