//
//  LibraryCollectionViewLayout.swift
//  MangaReader
//
//  Created by Juan on 2/25/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol LibraryCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForMangaAtIndexPath indexPath: IndexPath) -> CGFloat
}

class LibraryCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: LibraryCollectionViewLayoutDelegate!

    var cellWidth: CGFloat = 200
    var cellHeight: CGFloat = 300
    var cache = [UICollectionViewLayoutAttributes]()
    var contentHeight: CGFloat = 0
    var cellMinimumPadding: CGFloat = 10
    var cellVerticalPadding: CGFloat = 15
    var numberOfColumns: Int {
        var possibleNumberOfColumns = floor(self.contentWidth / self.cellWidth)
        while (possibleNumberOfColumns * self.cellWidth) + (self.cellMinimumPadding * (possibleNumberOfColumns - 1)) > self.contentWidth {
            possibleNumberOfColumns -= 1
        }
        return Int(possibleNumberOfColumns)
    }
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }

    override func prepare() {
        guard let collectionView = self.collectionView else {
            return
        }

        self.cache = [UICollectionViewLayoutAttributes]()

        var column: CGFloat = 0
        var row: CGFloat = 0
        let padding = (self.contentWidth - (CGFloat(self.numberOfColumns) * self.cellWidth)) / (CGFloat(self.numberOfColumns) - 1)
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let height = self.delegate.collectionView(collectionView, heightForMangaAtIndexPath: indexPath)
            let frame = CGRect(x: column * (self.cellWidth + padding), y: row * (self.cellHeight + self.cellVerticalPadding) + self.cellHeight - height, width: self.cellWidth, height: height)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            self.cache.append(attributes)

            self.contentHeight = max(self.contentHeight, frame.maxY)

            column += 1
            if Int(column) >= self.numberOfColumns {
                row += 1
                column = 0
            }
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in self.cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }

        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath.item]
    }
}
