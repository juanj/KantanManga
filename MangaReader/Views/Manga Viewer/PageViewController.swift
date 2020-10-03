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
    enum Side {
        case left, right, center

        func opposite() -> Side {
            if self == .center {
                return .center
            } else {
                return self == .left ? .right : .left
            }
        }
    }

    // Some times refreshView is called before the nib is loaded. Kepp these optional to prevent a crash
    @IBOutlet weak var pageImageView: AspectAlignImage?
    @IBOutlet weak var pageLabel: UILabel?
    @IBOutlet weak var leftGradientImage: UIImageView?
    @IBOutlet weak var rightGradientImage: UIImageView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!

    var pageImage: UIImage? {
        didSet {
            if pageImageView != nil {
                loadImage()
            }
        }
    }

    let pageNumber: Int
    let isPaddingPage: Bool
    var pageSide: Side
    private(set) weak var delegate: PageViewControllerDelegate?
    private let pageText: String
    private(set) var isFullScreened: Bool

    init(delegate: PageViewControllerDelegate?, pageSide: Side, pageNumber: Int, pageText: String? = nil, isFullScreened: Bool = false, isPaddingPage: Bool = false) {
        self.delegate = delegate
        self.pageSide = pageSide
        self.pageNumber = pageNumber
        self.pageText = pageText ?? "\(pageNumber + 1)"
        self.isFullScreened = isFullScreened
        self.isPaddingPage = isPaddingPage
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()
        pageLabel?.alpha = isFullScreened ? 0 : 1
        activityIndicator.isHidden = isPaddingPage

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        scrollView.delegate = self
        scrollView.maximumZoomScale = 3
    }

    func refreshView() {
        loadImage()
        switch pageSide {
        case .left:
            leftGradientImage?.isHidden = true
            rightGradientImage?.isHidden = false
            pageImageView?.alignment = .right
        case .right:
            leftGradientImage?.isHidden = false
            rightGradientImage?.isHidden = true
            pageImageView?.alignment = .left
        case .center:
            pageImageView?.alignment = .center
        }

        pageLabel?.text = pageText
    }

    @objc func tap() {
        delegate?.didTap(self)
    }

    private func loadImage() {
        guard let image = pageImage else { return }
        activityIndicator.stopAnimating()
        pageImageView?.image = image
    }
}

extension PageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
