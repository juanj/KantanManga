//
//  MangaCollectionCollectionViewCell.swift
//  Kantan-Manga
//
//  Created by Juan on 11/09/20.
//

import UIKit

class MangaCollectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageViews: [AspectAlignImage]!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageViews = imageViews.sorted(by: { $0.tag < $1.tag })
        for imageView in imageViews {
            imageView.transform = CGAffineTransform(rotationAngle: .random(in: -0.15...0.15))
        }
    }

    func setImages(_ images: [UIImage]) {
        for (image, imageView) in zip(images, imageViews) {
            imageView.image = image
        }
    }

}
