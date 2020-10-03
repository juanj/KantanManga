//
//  MangaCollectionViewCell.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

class MangaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var coverImageView: AspectAlignImage!
    @IBOutlet weak var pageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        coverImageView.alignment = .bottom
    }

    override func prepareForReuse() {
        pageLabel.text = "0/0"
        coverImageView.image = nil
        layer.zPosition = 0
    }
}
