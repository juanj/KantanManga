//
//  TagsLayout.swift
//  MangaReader
//
//  Created by Juan on 1/02/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

class TagsLayout: UICollectionViewFlowLayout {
    required override init() {super.init(); common()}
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder); common()}

    private func common() {
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        guard let attributes = super.layoutAttributesForElements(in: rect) else { return [] }
        var cellX: CGFloat = sectionInset.left
        var cellY: CGFloat = -1.0

        for attribute in attributes {
            if attribute.representedElementCategory != .cell { continue }

            if attribute.frame.origin.y >= cellY { cellX = sectionInset.left }
            attribute.frame.origin.x = cellX
            cellX += attribute.frame.width + minimumInteritemSpacing
            cellY = attribute.frame.maxY
        }
        return attributes
    }
}
