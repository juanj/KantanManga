//
//  OnboardingViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 10/10/20.
//

import UIKit

protocol OnboardingViewControllerDelegate: AnyObject {
    func didSelectLoadManga(_ onboardingViewController: OnboardingViewController)
    func didSelectNotNow(_ onboardingViewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var demoView: DemoOcrView!
    @IBOutlet weak var loadMangaButton: UIButton!
    @IBOutlet weak var notNowButton: UIButton!

    private weak var delegate: OnboardingViewControllerDelegate?
    init(delegate: OnboardingViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        configureStyle()
    }

    private func configureStyle() {
        demoView.layer.shadowRadius = 5
        demoView.layer.shadowColor = UIColor.black.cgColor
        demoView.layer.shadowOpacity = 0.5

        loadMangaButton.layer.cornerRadius = 15

        let attributedString = NSAttributedString(string: notNowButton.titleLabel?.text ?? "", attributes: [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 12), .underlineStyle: NSUnderlineStyle.single.rawValue])
        notNowButton.setAttributedTitle(attributedString, for: .normal)
    }

    @IBAction func loadDemoManga(_ sender: Any) {
        delegate?.didSelectLoadManga(self)
    }

    @IBAction func nowNow(_ sender: Any) {
        delegate?.didSelectNotNow(self)
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = min(round(scrollView.contentOffset.x / scrollView.frame.width), 2)
        pageControl.currentPage = Int(page)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = min(round(scrollView.contentOffset.x / scrollView.frame.width), 2)
        if page == 1 {
            demoView.startAnimation()
        }
    }
}
