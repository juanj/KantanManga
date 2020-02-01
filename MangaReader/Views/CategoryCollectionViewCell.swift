//
//  CategoryCollectionViewCell.swift
//  MangaReader
//
//  Created by Juan on 1/02/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 10
    }
}
