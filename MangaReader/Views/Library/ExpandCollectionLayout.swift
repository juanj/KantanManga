//
//  ExpandCollectionLayout.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/20.
//

import UIKit

class ExpandCollectionLayout: UICollectionViewFlowLayout {
    var originPoint: CGPoint

    init(originPoint: CGPoint) {
        self.originPoint = originPoint
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.center = originPoint
        return attributes
    }
}
