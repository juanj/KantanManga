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

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        pageImageView.image = image

        configureNavigationBar()
    }

    func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
    }

    @objc func back() {
        delegate?.didSelectBack(self)
    }
}

extension PageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pageImageView
    }
}
