//
//  AspectAlignImage.swift
//  Kantan-Manga
//
//  Created by Juan on 14/09/20.
//

import Foundation
import UIKit

class AspectAlignImage: UIView {
    var image: UIImage? {
        didSet {
            sizeImage()
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: frame.width)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: frame.height)

        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true

        return imageView
    }()

    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?

    private func sizeImage() {
        imageView.image = image
        guard let image = image else { return }
        let size = CGSize.aspectFit(size: image.size, inside: frame.size)
        imageWidthConstraint?.constant = size.width
        imageHeightConstraint?.constant = size.height

        layoutIfNeeded()
    }
}
