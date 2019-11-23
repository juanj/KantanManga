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
    func didSelectBack(_ pageViewController: PageViewController)
    func didTap(_ pageViewController: PageViewController)
    func didLongPress(_ pageViewController: PageViewController)
}

class PageViewController: UIViewController {
    // Some times refreshView is called before the nib is loaded. Kepp these optional to prevent a crash
    @IBOutlet weak var pageImageView: UIImageViewAligned?
    @IBOutlet weak var backButton: UIButton?
    @IBOutlet weak var pageLabel: UILabel?
    @IBOutlet weak var leftGradientImage: UIImageView?
    @IBOutlet weak var rightGradientImage: UIImageView?
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()

        if fullScreen {
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            backButton?.alpha = 0
            view.layoutIfNeeded()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        view.addGestureRecognizer(longPressGesture)
    }

    func refreshView() {
        loadImage()
        if doublePaged {
            if page % 2 == 1 {
                leftGradientImage?.isHidden = true
                rightGradientImage?.isHidden = false
                backButton?.isHidden = false
                pageImageView?.alignLeft = false
                pageImageView?.alignRight = true
            } else {
                leftGradientImage?.isHidden = false
                rightGradientImage?.isHidden = true
                backButton?.isHidden = true
                pageImageView?.alignLeft = true
                pageImageView?.alignRight = false
            }
        } else {
            backButton?.isHidden = false
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

    func toggleBars() {
        if fullScreen {
            fullScreen = false
            topConstraint.constant = 45
            bottomConstraint.constant = 45
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.backButton?.alpha = 1
            }
        } else {
            fullScreen = true
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.backButton?.alpha = 0
            }
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    @objc func tap() {
        delegate?.didTap(self)
    }

    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.didLongPress(self)
        }
    }

    @IBAction func back(_ sender: Any) {
        delegate?.didSelectBack(self)
    }
}
