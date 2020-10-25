//
//  KanjiCollectionViewCell.swift
//  Kantan-Manga
//
//  Created by Juan on 22/10/20.
//

import UIKit

class KanjiCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var kanjiLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        kanjiLabel.backgroundColor = .clear
        kanjiLabel.textColor = .label
    }
}
