//
//  MangaCollectionViewCell.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import UIImageViewAlignedSwift

class MangaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var coverImageView: UIImageViewAligned!
    @IBOutlet weak var pageLabel: UILabel!

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == NSSelectorFromString("deleteCollectionCell")
    }

    override func prepareForReuse() {
        pageLabel.text = "0/0"
        coverImageView.image = nil
    }

    @objc func deleteCollectionCell() {
        if let collectionView = superview as? UICollectionView, let delegate = collectionView.delegate {
            delegate.collectionView!(collectionView, performAction: NSSelectorFromString("deleteCollectionCell"), forItemAt: collectionView.indexPath(for: self)!, withSender: self)
        }
    }
}
