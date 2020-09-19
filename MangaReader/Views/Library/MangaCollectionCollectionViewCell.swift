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

    var rotations = [CGAffineTransform]() {
        didSet {
            for (imageView, rotation) in zip(imageViews, rotations) {
                imageView.transform = rotation
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imageViews = imageViews.sorted(by: { $0.tag < $1.tag })
    }

    override func prepareForReuse() {
        for image in imageViews {
            image.image = nil
            image.transform = .identity
        }
    }

    func setImages(_ images: [UIImage]) {
        for (image, imageView) in zip(images, imageViews) {
            imageView.image = image
        }
    }
}
