//
//  PageDetailViewController.swift
//  MangaReader
//
//  Created by Juan on 2/25/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol PageDetailViewControllerDelegate: AnyObject {
    func didSelectBack(_ pageDetailViewController: PageDetailViewController)
}

class PageDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageImageView: UIImageView!
    var image: UIImage?
    weak var delegate: PageDetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 10.0
        self.pageImageView.image = self.image

        self.configureNavigationBar()
    }

    func configureNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
    }

    @objc func back() {
        self.delegate?.didSelectBack(self)
    }
}

extension PageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.pageImageView
    }
}
