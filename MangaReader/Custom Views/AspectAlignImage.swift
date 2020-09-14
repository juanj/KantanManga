//
//  AspectAlignImage.swift
//  Kantan-Manga
//
//  Created by Juan on 14/09/20.
//

import Foundation
import UIKit

class AspectAlignImage: UIView {
    enum ImageAlignment {
        case left, top, right, bottom
    }
    var image: UIImage? {
        didSet {
            sizeImage()
        }
    }

    var alignment: ImageAlignment = .bottom {
        didSet {
            activateConstraints()
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        imageBottomConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        imageTopConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
        imageLeftConstraint = imageView.leftAnchor.constraint(equalTo: leftAnchor)
        imageRightConstraint = imageView.rightAnchor.constraint(equalTo: rightAnchor)
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: frame.width)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: frame.height)

        activateConstraints()

        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true

        return imageView
    }()

    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    private var imageBottomConstraint: NSLayoutConstraint?
    private var imageTopConstraint: NSLayoutConstraint?
    private var imageLeftConstraint: NSLayoutConstraint?
    private var imageRightConstraint: NSLayoutConstraint?

    private func sizeImage() {
        imageView.image = image
        guard let image = image else { return }
        let size = CGSize.aspectFit(size: image.size, inside: frame.size)
        imageWidthConstraint?.constant = size.width
        imageHeightConstraint?.constant = size.height

        layoutIfNeeded()
    }

    private func activateConstraints() {
        imageBottomConstraint?.isActive = true
        imageTopConstraint?.isActive = true
        imageLeftConstraint?.isActive = true
        imageRightConstraint?.isActive = true

        switch alignment {
        case .left:
            imageRightConstraint?.isActive = false
        case .top:
            imageBottomConstraint?.isActive = false
        case .right:
            imageLeftConstraint?.isActive = false
        case .bottom:
            imageTopConstraint?.isActive = true
        }

        layoutIfNeeded()
    }
}
