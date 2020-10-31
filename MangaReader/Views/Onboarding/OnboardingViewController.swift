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
    func didSelectEnableKeyboard(_ onboardingViewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var demoView: DemoOcrView!
    @IBOutlet weak var loadMangaButton: UIButton!
    @IBOutlet weak var notNowButton: UIButton!
    @IBOutlet weak var keyboardImageView: UIImageView!
    @IBOutlet weak var enableKeyboardButton: UIButton!

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

    func goToLastPage() {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(pageControl.numberOfPages - 1), y: 0), animated: true)
    }

    private func configureStyle() {
        demoView.layer.shadowRadius = 5
        demoView.layer.shadowColor = UIColor.black.cgColor
        demoView.layer.shadowOpacity = 0.5

        loadMangaButton.layer.cornerRadius = 15
        enableKeyboardButton.layer.cornerRadius = 15

        let attributedString = NSAttributedString(string: notNowButton.titleLabel?.text ?? "", attributes: [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 12), .underlineStyle: NSUnderlineStyle.single.rawValue])
        notNowButton.setAttributedTitle(attributedString, for: .normal)
    }

    private func startKeyboardAnimation() {
        keyboardImageView.animationImages = [UIImage(named: "k1"), UIImage(named: "k2"), UIImage(named: "k3"), UIImage(named: "k4"), UIImage(named: "k4")]
            .compactMap { $0 }
        keyboardImageView.animationDuration = 3
        keyboardImageView.startAnimating()
    }

    @IBAction func loadDemoManga(_ sender: Any) {
        delegate?.didSelectLoadManga(self)
    }

    @IBAction func nowNow(_ sender: Any) {
        delegate?.didSelectNotNow(self)
    }

    @IBAction func enableKeyboard(_ sender: Any) {
        delegate?.didSelectEnableKeyboard(self)
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = min(Int(round(scrollView.contentOffset.x / scrollView.frame.width)), pageControl.numberOfPages - 1)
        pageControl.currentPage = page
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = min(Int(round(scrollView.contentOffset.x / scrollView.frame.width)), pageControl.numberOfPages - 1)
        if page == 1 {
            demoView.startAnimation()
        } else if page == 2 {
            startKeyboardAnimation()
        }
    }
}
