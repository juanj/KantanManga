//
//  MangaViewController.swift
//  MangaReader
//
//  Created by Juan on 26/11/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import Firebase

protocol MangaViewControllerDelegate: AnyObject {
    func didTapPage(mangaViewController: MangaViewController, pageViewController: PageViewController)
    func back(mangaViewController: MangaViewController)
}

class MangaViewController: UIViewController {
    private let manga: Manga
    private let dataSource: MangaDataSource
    private weak var delegate: MangaViewControllerDelegate?

    private var pageController: UIPageViewController!
    private var selectionView = SelectionView()
    private var sentenceView: AnalyzeTextViewController!
    private var sentenceViewTopConstraint: NSLayoutConstraint!

    private var isPageAnimating = false
    private var fullScreen = false
    private var ocrEnabled = false

    override var prefersStatusBarHidden: Bool {
        return fullScreen
    }

    init(manga: Manga, dataSource: MangaDataSource, delegate: MangaViewControllerDelegate) {
        self.manga = manga
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        createPageController()
        configurePageControllerConstraints()
        configureSelectionView()
        configureSentenceView()
    }

    private func configureSelectionView() {
        view.addSubview(selectionView)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.isHidden = true
        selectionView.delegate = self

        let topConstraint = selectionView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = selectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leadingConstraint = selectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = selectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }

    private func configureNavBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton

        let ocrButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass.circle", withConfiguration: nil), style: .plain, target: self, action: #selector(toggleOcr))
        navigationItem.rightBarButtonItem = ocrButton
    }

    private func createPageController() {
        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [UIViewController]()

        if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation, orientation == .portraitUpsideDown || orientation == .portrait {
            spineLocation = .max
            doublePaged = false
            let page = dataSource.createPage(index: Int(manga.currentPage), doublePaged: doublePaged, delegate: self)
            viewControllers = [page]
        } else {
            spineLocation = .mid
            doublePaged = true

            if manga.currentPage % 2 == 1 {
                let page1 = dataSource.createPage(index: Int(manga.currentPage - 1), doublePaged: doublePaged, delegate: self)
                let page2 = dataSource.createPage(index: Int(manga.currentPage), doublePaged: doublePaged, delegate: self)

                // Set view controllers in this order to make manga RTL
                viewControllers = [page2, page1]
            } else {
                let page1 = dataSource.createPage(index: Int(manga.currentPage), doublePaged: doublePaged, delegate: self)
                let page2 = dataSource.createPage(index: Int(manga.currentPage + 1), doublePaged: doublePaged, delegate: self)

                // Set view controllers in this order to make manga RTL
                viewControllers = [page2, page1]
            }
        }

        pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.spineLocation: spineLocation.rawValue])
        pageController.isDoubleSided = doublePaged
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)

    }

    private func configurePageControllerConstraints() {
        view.addSubview(pageController.view)
        addChild(pageController)

        pageController.view.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = pageController.view.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leadingConstraint = pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }

    private func configureSentenceView() {
        sentenceView = AnalyzeTextViewController(sentence: [])
        view.addSubview(sentenceView)

        sentenceViewTopConstraint = sentenceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        let leftConstraint = sentenceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
        let rightConstraint = sentenceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)

        view.addConstraints([sentenceViewTopConstraint, leftConstraint, rightConstraint])
    }

    func toggleFullscreen() {
        fullScreen = !fullScreen
        setNeedsStatusBarAppearanceUpdate()
        if fullScreen && sentenceViewTopConstraint.constant < 0 {
            sentenceViewTopConstraint.constant = 0
            UIView.animate(withDuration: 0.15) {
                self.view.layoutIfNeeded()
            }
        } else if !fullScreen && sentenceViewTopConstraint.constant == 0 {
            sentenceViewTopConstraint.constant = -100
            UIView.animate(withDuration: 0.15) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func back() {
        delegate?.back(mangaViewController: self)
    }

    @objc func toggleOcr() {
        ocrEnabled = !ocrEnabled
        selectionView.isHidden = !selectionView.isHidden
    }
}

// MARK: PageViewControllerDelegate
extension MangaViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if isPageAnimating || ocrEnabled {
            return nil
        }
        // Return next page to make manga RTL
        return dataSource.nextPage(currentPage: viewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if isPageAnimating || ocrEnabled {
            return nil
        }
        // Return previous page to make manga RTL
        return dataSource.previousPage(currentPage: viewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [PageViewController]()

        isPageAnimating = false

        switch orientation {
        case .portrait, .portraitUpsideDown:
            spineLocation = .max
            doublePaged = false
            if let pages = pageViewController.viewControllers as? [PageViewController] {
                if pages.count == 2 {
                    // Two pages. Keep the one on the right.
                    viewControllers = [pages[1]]
                } else {
                    // Just one page. Use the same
                    viewControllers = pages
                }
            }
        default:
            //.landscapeLeft, .landscapeRight, .unknown:
            spineLocation = .mid
            doublePaged = true
            if let pages = pageViewController.viewControllers as? [PageViewController] {
                if pages.count == 2 {
                    viewControllers = pages
                } else {
                    let page = pages[0]
                    if page.page % 2 == 0 {
                        // If first page is even, get next page
                        if let page2 = dataSource.nextPage(currentPage: page) as? PageViewController {
                            viewControllers = [page2, page]
                        }
                    } else {
                        // If first page is odd, get previous page
                        if let page2 = dataSource.previousPage(currentPage: page) as? PageViewController {
                            viewControllers = [page, page2]
                        }
                    }
                }
            }
        }

        for page in viewControllers {
            page.doublePaged = doublePaged
            page.refreshView()
        }

        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        pageViewController.isDoubleSided = doublePaged

        return spineLocation
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let pageView = pageViewController.viewControllers?[0] as? PageViewController {
            CoreDataManager.sharedManager.updatePage(manga: manga, newPage: Int16(pageView.page))
        }

        if completed || finished {
            isPageAnimating = false
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        isPageAnimating = true
    }
}

// MARK: PageViewControllerDelegate
extension MangaViewController: PageViewControllerDelegate {
    func didTap(_ pageViewController: PageViewController) {
        delegate?.didTapPage(mangaViewController: self, pageViewController: pageViewController)
    }
}

// MARK: SelectionViewDelegate
extension MangaViewController: SelectionViewDelegate {
    func didSelectSection(_ selectionView: SelectionView, section: CGRect) {
        UIGraphicsBeginImageContextWithOptions(section.size, true, 1)
        self.view.drawHierarchy(in: CGRect(x: -section.origin.x, y: -section.origin.y, width: self.view.frame.width, height: self.view.frame.height), afterScreenUpdates: true)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["ja"]
        let textRecognizer = vision.cloudTextRecognizer()

        guard let image = capturedImage else { return }
        let visionImage = VisionImage(image: image)
        textRecognizer.process(visionImage) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let result = result else { return }

            let text = result.text.replacingOccurrences(of: "\n", with: " ")

            let tokenizer = Tokenizer()
            let tokens = tokenizer.parse(text)
            let sentence = tokens.map {JapaneseWord(text: $0.surface, rootForm: $0.originalForm ?? $0.surface, furigana: $0.pronunciation != nil ? [Furigana(kana: $0.pronunciation!, range: NSRange(location: 0, length: $0.surface.count))] : [] )}
            DispatchQueue.main.async {
                self.sentenceView.sentence = sentence
            }
        }
    }
}
