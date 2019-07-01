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
        self.contentHeight = 0

        var column: Int = 0
        var row = 0
        var rowsHeight: [CGFloat] = {
            var rows = [CGFloat]()
            for _ in 0 ..< self.calculateNumberOfRows() {
                rows.append(0.0)
            }
            return rows
        }()
        var currentRow = [UICollectionViewLayoutAttributes]()
        var totalHeight: CGFloat = 0
        let padding: CGFloat
        if self.numberOfColumns == 1 {
            // Prevent division by 0
            padding = (self.contentWidth - self.cellWidth) / 2
        } else {
            padding = (self.contentWidth - (CGFloat(self.numberOfColumns) * self.cellWidth)) / (CGFloat(self.numberOfColumns) - 1)
        }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for item in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let height = self.delegate.collectionView(collectionView, heightForMangaAtIndexPath: indexPath)
            rowsHeight[row] = max(rowsHeight[row], height)
            var xPos = CGFloat(column) * (self.cellWidth + padding)
            if column == 0 && self.numberOfColumns == 1 {
                xPos += padding
            }
            let frame = CGRect(x: xPos, y: height, width: self.cellWidth, height: height)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            currentRow.append(attributes)

            column += 1
            if column >= self.numberOfColumns || item == numberOfItems - 1 {
                for attributes in currentRow {
                    attributes.frame.origin.y = totalHeight + self.cellVerticalPadding + rowsHeight[row] - attributes.frame.origin.y
                    self.cache.append(attributes)
                }
                currentRow = [UICollectionViewLayoutAttributes]()
                totalHeight += rowsHeight[row]
                row += 1
                column = 0
            }
        }
        self.contentHeight = max(self.contentHeight, self.cache.last?.frame.maxY ?? 0)
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

    private func calculateNumberOfRows() -> Int {
        guard let collectionView = self.collectionView else {
            return 0
        }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfRows = ceil(Float(numberOfItems) / Float(self.numberOfColumns))

        return Int(numberOfRows)
    }
}
