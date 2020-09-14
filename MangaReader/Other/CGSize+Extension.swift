//
//  CGSize+Extension.swift
//  Kantan-Manga
//
//  Created by Juan on 14/09/20.
//

import Foundation

extension CGSize {
    static func aspectFit(size: CGSize, inside boundingSize: CGSize) -> CGSize {
        var finalSize = boundingSize
        let widthProportion = boundingSize.width / size.width
        let heightProportion = boundingSize.height / size.height

        if heightProportion < widthProportion {
            finalSize.width = boundingSize.height / size.height * size.width
        } else if widthProportion < heightProportion {
            finalSize.height = boundingSize.width / size.width * size.height
        }

        return finalSize
    }
}
