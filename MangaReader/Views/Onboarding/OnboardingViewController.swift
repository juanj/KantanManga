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
    @IBOutlet weak var demoView: DemoOcrView!

    private var shapeLayer: CAShapeLayer!
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        demoView.layer.shadowRadius = 5
        demoView.layer.shadowColor = UIColor.black.cgColor
        demoView.layer.shadowOpacity = 0.5
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = min(round(scrollView.contentOffset.x / scrollView.frame.width), 2)
        pageControl.currentPage = Int(page)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = min(round(scrollView.contentOffset.x / scrollView.frame.width), 2)
        if page == 2 {
            demoView.startAnimation()
        }
    }
}
