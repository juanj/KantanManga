//
//  PageViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate {
    func didSelectBack(_ pageViewController: PageViewController)
}

class PageViewController: UIViewController {
    // Some times refreshView is called before the nib is loaded. Kepp these optional to prevent a crash
    @IBOutlet weak var pageImageView: UIImageView?
    @IBOutlet weak var backButton: UIButton?
    
    var delegate: PageViewControllerDelegate?
    var doublePaged = false
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
    }
    
    func refreshView() {
        self.loadImage()
        if self.doublePaged {
            if self.page % 2 == 1 {
                self.backButton?.isHidden = false
            } else {
                self.backButton?.isHidden = true
            }
        } else {
            self.backButton?.isHidden = false
        }
    }
    
    func loadImage() {
        if let pageImage = UIImage(data: self.pageData) {
            self.pageImageView?.image = pageImage
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.delegate?.didSelectBack(self)
    }
}
