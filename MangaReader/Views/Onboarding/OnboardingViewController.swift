//
//  OnboardingViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 10/10/20.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = min(round(scrollView.contentOffset.x / scrollView.frame.width), 3)
        pageControl.currentPage = Int(page)
      }
}
