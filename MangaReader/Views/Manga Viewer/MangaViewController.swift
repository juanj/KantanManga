//
//  MangaViewController.swift
//  MangaReader
//
//  Created by Juan on 26/11/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol MangaViewControllerDelegate: AnyObject {
    func didTapPage(mangaViewController: MangaViewController, pageViewController: PageViewController)
    func back(mangaViewController: MangaViewController)
    func didSelectSectionOfImage(mangaViewController: MangaViewController, image: UIImage)
}

class MangaViewController: UIViewController {
    private let manga: Manga
    private let dataSource: MangaDataSource
    private weak var delegate: MangaViewControllerDelegate?

    private var pageController: UIPageViewController!
    private var selectionView = SelectionView()
    private var japaneseHelp: JapaneseHelpViewController!
    private var japaneseHelpBottomConstraint: NSLayoutConstraint!

    private var isPageAnimating = false
    private var fullScreen = false
    private var ocrEnabled = false
    private var ocrActivityIndicator = UIActivityIndicatorView(style: .medium)

    private var panInitialPosition: CGFloat = 0

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
      return .bottom
    }

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
        configureJapaneseHelpView()
        configureKeyboard()
        startAtFullScreen()
    }

    private func configureNavBar() {
        title = manga.name
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton

        let ocrButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass.circle", withConfiguration: nil), style: .plain, target: self, action: #selector(toggleOcr))

        ocrActivityIndicator.hidesWhenStopped = true
        let ocrLoadingNavButton = UIBarButtonItem(customView: ocrActivityIndicator)
        navigationItem.rightBarButtonItems = [ocrButton, ocrLoadingNavButton]
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

    private func configureJapaneseHelpView() {
        japaneseHelp = JapaneseHelpViewController(delegate: self)
        japaneseHelp.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(japaneseHelp)
        view.addSubview(japaneseHelp.view)
        japaneseHelp.didMove(toParent: self)

        let leftConstraint = japaneseHelp.view.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = japaneseHelp.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        let topConstraint = japaneseHelp.view.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor)
        japaneseHelpBottomConstraint = japaneseHelp.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        topConstraint.priority = .required
        japaneseHelpBottomConstraint.priority = .defaultLow

        view.addConstraints([leftConstraint, rightConstraint, topConstraint, japaneseHelpBottomConstraint])

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(pan:)))
        edgePan.edges = .bottom
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)
    }

    private func configureKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func startAtFullScreen() {
        fullScreen = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        setNeedsStatusBarAppearanceUpdate()
        japaneseHelpBottomConstraint.constant = 100
        self.view.layoutIfNeeded()
    }

    func toggleFullscreen() {
        fullScreen = !fullScreen
        navigationController?.setNavigationBarHidden(fullScreen, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        if !fullScreen && japaneseHelpBottomConstraint.constant == japaneseHelp.view.frame.height {
            if japaneseHelp.isDictionaryOpen {
                japaneseHelpBottomConstraint.constant = japaneseHelp.dictionaryHeight
            } else {
                japaneseHelpBottomConstraint.constant = 0
            }
            UIView.animate(withDuration: 0.15) {
                self.view.layoutIfNeeded()
            }
        } else if fullScreen && japaneseHelpBottomConstraint.constant < japaneseHelp.view.frame.height {
            japaneseHelpBottomConstraint.constant = japaneseHelp.view.frame.height
            UIView.animate(withDuration: 0.15) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func setSentence(sentence: String) {
        japaneseHelp.setSentence(text: sentence)
    }

    func ocrStartLoading() {
        ocrActivityIndicator.startAnimating()
    }

    func ocrEndLoading() {
        ocrActivityIndicator.stopAnimating()
    }

    @objc func back() {
        delegate?.back(mangaViewController: self)
    }

    @objc func toggleOcr() {
        ocrEnabled = !ocrEnabled
        selectionView.isHidden = !selectionView.isHidden
        if fullScreen != ocrEnabled {
            toggleFullscreen()
        }
    }

    @objc func handleKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        if frame.origin.y >= view.frame.height {
            japaneseHelpBottomConstraint.constant = 0
        } else {
            japaneseHelpBottomConstraint.constant = -frame.height
        }
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func handleEdgePan(pan: UIScreenEdgePanGestureRecognizer) {
        guard japaneseHelpBottomConstraint.constant > 0 else { return }
        let velocity = pan.velocity(in: view)
        if !japaneseHelp.isDictionaryOpen || (japaneseHelp.isDictionaryOpen && velocity.y < -1300) {
            japaneseHelpBottomConstraint.constant = 0
        } else {
            japaneseHelpBottomConstraint.constant = japaneseHelp.dictionaryHeight
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            manga.currentPage = Int16(pageView.page)
            CoreDataManager.sharedManager.updateManga(manga: manga)
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
        guard section.width != 0 && section.height != 0 else { return }
        UIGraphicsBeginImageContextWithOptions(section.size, true, 1)
        self.view.drawHierarchy(in: CGRect(x: -section.origin.x, y: -section.origin.y, width: self.view.frame.width, height: self.view.frame.height), afterScreenUpdates: true)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        toggleOcr()
        guard let image = capturedImage else { return }
        delegate?.didSelectSectionOfImage(mangaViewController: self, image: image)
    }
}

extension MangaViewController: JapaneseHelpViewControllerDelegate {
    func handlePan(japaneseHelpViewController: JapaneseHelpViewController, pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        let velocity = pan.velocity(in: view)
        if pan.state == .began {
            panInitialPosition = japaneseHelpBottomConstraint.constant
        } else if pan.state == .changed {
            japaneseHelpBottomConstraint.constant = panInitialPosition + translation.y
            if japaneseHelpBottomConstraint.constant < 0 {
                japaneseHelpBottomConstraint.constant = 0
            }

            if velocity.y > 1300 {
                // Fast pan down
                japaneseHelpBottomConstraint.constant = japaneseHelp.isDictionaryOpen ? japaneseHelp.view.frame.height - 100 : japaneseHelp.dictionaryHeight
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            } else if japaneseHelp.isDictionaryOpen && velocity.y < -1300 {
                // fast pan up
                japaneseHelpBottomConstraint.constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            } else {
                view.layoutIfNeeded()
            }
        } else if pan.state == .ended {
            let currentValue = japaneseHelpBottomConstraint.constant
            // Dictionary open and pan pass the middle of the dictionary
            if japaneseHelp.isDictionaryOpen &&
                japaneseHelpBottomConstraint.constant > japaneseHelp.dictionaryHeight / 2 {

                // Pan pass middle of text view
                if japaneseHelpBottomConstraint.constant > japaneseHelp.view.frame.height - 50 {
                    japaneseHelpBottomConstraint.constant = japaneseHelp.view.frame.height
                } else {
                    japaneseHelpBottomConstraint.constant = japaneseHelp.dictionaryHeight
                }
            } else {
                // Pan pass middle of text view
                if japaneseHelpBottomConstraint.constant > japaneseHelp.view.frame.height / 2 {
                    japaneseHelpBottomConstraint.constant = japaneseHelp.view.frame.height
                } else {
                    japaneseHelpBottomConstraint.constant = 0
                }
            }
            UIView.animate(withDuration: TimeInterval(abs(currentValue - japaneseHelpBottomConstraint.constant) * 0.002)) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func didOpenDictionary(japaneseHelpViewController: JapaneseHelpViewController) {
        if japaneseHelpBottomConstraint.constant != 0 {
            japaneseHelpBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension MangaViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
