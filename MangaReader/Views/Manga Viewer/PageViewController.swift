//
//  PageViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate: AnyObject {
    func didTap(_ pageViewController: PageViewController)
}

class PageViewController: UIViewController {
    // Some times refreshView is called before the nib is loaded. Kepp these optional to prevent a crash
    @IBOutlet weak var pageImageView: AspectAlignImage?
    @IBOutlet weak var pageLabel: UILabel?
    @IBOutlet weak var leftGradientImage: UIImageView?
    @IBOutlet weak var rightGradientImage: UIImageView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!

    weak var delegate: PageViewControllerDelegate?
    var doublePaged = false
    var offset = 0
    var fullScreen = false
    var pageImage: UIImage? {
        didSet {
            if pageImageView != nil {
                loadImage()
            }
        }
    }
    var page = 0
    var isPaddingPage = false
    private var lastContentOffset: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()

        if fullScreen {
            pageLabel?.alpha = 0
        }

        if isPaddingPage {
            activityIndicator.stopAnimating()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        scrollView.delegate = self
        scrollView.maximumZoomScale = 3
    }

    func refreshView() {
        loadImage()
        if doublePaged {
            if page % 2 != offset {
                leftGradientImage?.isHidden = true
                rightGradientImage?.isHidden = false
                pageImageView?.alignment = .right
            } else {
                leftGradientImage?.isHidden = false
                rightGradientImage?.isHidden = true
                pageImageView?.alignment = .left
            }
        } else {
            pageImageView?.alignment = .center
        }
        if isPaddingPage {
            pageLabel?.text = ""
        } else {
            pageLabel?.text = "\(page + 1)"
        }
    }

    @objc func tap() {
        delegate?.didTap(self)
    }

    private func loadImage() {
        if pageImage != nil {
            activityIndicator.stopAnimating()
        }
        pageImageView?.image = pageImage
    }
}

extension PageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
