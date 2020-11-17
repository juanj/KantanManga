//
//  FakeCollectionView.swift
//  Kantan-MangaTests
//
//  Created by Juan on 17/11/20.
//

import UIKit

class FakeCollectionView: UICollectionView {
    override var indexPathsForSelectedItems: [IndexPath]? {
        return [IndexPath(row: 0, section: 0)]
    }

    override func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        return UICollectionViewCell()
    }
}
