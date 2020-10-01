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

    private var imageView = UIImageView()
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

        imageBottomConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        imageTopConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
        imageLeftConstraint = imageView.leftAnchor.constraint(equalTo: leftAnchor)
        imageRightConstraint = imageView.rightAnchor.constraint(equalTo: rightAnchor)
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: frame.width)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: frame.height)
        imageCenterXConstraint = imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        imageCenterYConstraint = imageView.centerYAnchor.constraint(equalTo: centerYAnchor)

        activateConstraints()
    }

    private func sizeImage() {
        imageView.image = image
        guard let image = image else { return }
        let size = CGSize.aspectFit(size: image.size, inside: frame.size)
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
        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true

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
