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
        case left, top, right, bottom, center
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

    var imageView = UIImageView()
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    private var imageBottomConstraint: NSLayoutConstraint?
    private var imageTopConstraint: NSLayoutConstraint?
    private var imageLeftConstraint: NSLayoutConstraint?
    private var imageRightConstraint: NSLayoutConstraint?
    private var imageCenterXConstraint: NSLayoutConstraint?
    private var imageCenterYConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImageView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureImageView()
    }

    override func layoutSubviews() {
        sizeImage()
        super.layoutSubviews()
    }

    private func configureImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        (imageTopConstraint, imageLeftConstraint, imageBottomConstraint, imageRightConstraint) = imageView.addConstraintsTo(self)
        (imageCenterXConstraint, imageCenterYConstraint) = imageView.addCenterConstraintsTo(self)
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: bounds.width)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: bounds.height)

        // Width and height are always active
        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true

        activateConstraints()
    }

    private func sizeImage() {
        imageView.image = image
        guard let image = image else { return }
        let size = CGSize.aspectFit(size: image.size, inside: bounds.size)
        imageWidthConstraint?.constant = size.width
        imageHeightConstraint?.constant = size.height

        layoutIfNeeded()
    }

    private func activateConstraints() {
        imageBottomConstraint?.isActive = false
        imageTopConstraint?.isActive = false
        imageLeftConstraint?.isActive = false
        imageRightConstraint?.isActive = false
        imageCenterXConstraint?.isActive = false
        imageCenterYConstraint?.isActive = false

        switch alignment {
        case .left:
            imageLeftConstraint?.isActive = true
            imageCenterYConstraint?.isActive = true
        case .top:
            imageTopConstraint?.isActive = true
            imageCenterXConstraint?.isActive = true
        case .right:
            imageRightConstraint?.isActive = true
            imageCenterYConstraint?.isActive = true
        case .bottom:
            imageBottomConstraint?.isActive = true
            imageCenterXConstraint?.isActive = true
        case .center:
            imageCenterXConstraint?.isActive = true
            imageCenterYConstraint?.isActive = true
        }

        layoutIfNeeded()
    }
}
