//
//  PageViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import UIImageViewAlignedSwift

protocol PageViewControllerDelegate: AnyObject {
    func didTap(_ pageViewController: PageViewController)
}

class PageViewController: UIViewController {
    // Some times refreshView is called before the nib is loaded. Kepp these optional to prevent a crash
    @IBOutlet weak var pageImageView: UIImageViewAligned?
    @IBOutlet weak var pageLabel: UILabel?
    @IBOutlet weak var leftGradientImage: UIImageView?
    @IBOutlet weak var rightGradientImage: UIImageView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!

    weak var delegate: PageViewControllerDelegate?
    var doublePaged = false
    var fullScreen = false
    var pageData = Data() {
        didSet {
            if pageImageView != nil {
                loadImage()
            }
        }
    }
    var page = 0
    private var lastContentOffset: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()

        if fullScreen {
            pageLabel?.alpha = 0
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
            if page % 2 == 1 {
                leftGradientImage?.isHidden = true
                rightGradientImage?.isHidden = false
                pageImageView?.alignLeft = false
                pageImageView?.alignRight = true
            } else {
                leftGradientImage?.isHidden = false
                rightGradientImage?.isHidden = true
                pageImageView?.alignLeft = true
                pageImageView?.alignRight = false
            }
        } else {
            pageImageView?.alignLeft = false
            pageImageView?.alignRight = false
        }
        pageLabel?.text = "\(page + 1)"
    }

    func loadImage() {
        if let pageImage = UIImage(data: pageData) {
            activityIndicator.stopAnimating()
            pageImageView?.image = pageImage
        }
    }

    @objc func tap() {
        delegate?.didTap(self)
    }
}

extension PageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
