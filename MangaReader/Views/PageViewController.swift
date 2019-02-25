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
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    weak var delegate: PageViewControllerDelegate?
    var doublePaged = false
    var fullScreen = false
    var pageData = Data() {
        didSet {
            if self.pageImageView != nil {
                self.loadImage()
            }
        }
    }
    var page = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshView()

        if self.fullScreen {
            self.topConstraint.constant = 0
            self.bottomConstraint.constant = 0
            self.backButton?.alpha = 0
            self.view.layoutIfNeeded()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        self.view.addGestureRecognizer(longPressGesture)
    }

    func refreshView() {
        self.loadImage()
        if self.doublePaged {
            if self.page % 2 == 1 {
                self.backButton?.isHidden = false
                self.pageImageView?.alignLeft = false
                self.pageImageView?.alignRight = true
            } else {
                self.backButton?.isHidden = true
                self.pageImageView?.alignLeft = true
                self.pageImageView?.alignRight = false
            }
        } else {
            self.backButton?.isHidden = false
            self.pageImageView?.alignLeft = false
            self.pageImageView?.alignRight = false
        }
        self.pageLabel?.text = "\(self.page + 1)"
    }

    func loadImage() {
        if let pageImage = UIImage(data: self.pageData) {
            self.pageImageView?.image = pageImage
        }
    }

    func toggleBars() {
        if self.fullScreen {
            self.fullScreen = false
            self.topConstraint.constant = 45
            self.bottomConstraint.constant = 45
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.backButton?.alpha = 1
            }
        } else {
            self.fullScreen = true
            self.topConstraint.constant = 0
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.backButton?.alpha = 0
            }
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }

    @objc func tap() {
        self.delegate?.didTap(self)
    }

    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.delegate?.didLongPress(self)
        }
    }

    @IBAction func back(_ sender: Any) {
        self.delegate?.didSelectBack(self)
    }
}
