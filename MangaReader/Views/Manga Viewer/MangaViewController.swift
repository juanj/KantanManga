//
//  MangaViewController.swift
//  MangaReader
//
//  Created by Juan on 26/11/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol MangaViewControllerDelegate: AnyObject {
    func didTapPage(_ mangaViewController: MangaViewController, pageViewController: PageViewController)
    func back(_ mangaViewController: MangaViewController)
    func didSelectSectionOfImage(_ mangaViewController: MangaViewController, image: UIImage)
    func didTapSettings(_ mangaViewController: MangaViewController)
    func pageDidChange(_ mangaViewController: MangaViewController, manga: Manga, newPage: Int)
    func didTapCreateAnkiCard(_ mangaViewController: MangaViewController, image: UIImage, sentence: String, dictionaryResult: SearchTermResult)
}

class MangaViewController: UIViewController {
    private let manga: Manga
    private let dataSource: MangaDataSourceable
    private weak var delegate: MangaViewControllerDelegate?
    private let firstTime: Bool

    private var pageController: UIPageViewController!
    private var selectionView = SelectionView()
    private lazy var japaneseHelp = JapaneseHelpViewController(delegate: self)
    private var japaneseHelpBottomConstraint: NSLayoutConstraint!
    private let progressBar = UISlider()
    private var oldPageValue = 0

    private var isPageAnimating = false
    private var fullScreen = false
    private var ocrEnabled = false
    private var ocrActivityIndicator = UIActivityIndicatorView(style: .medium)

    private var panInitialPosition: CGFloat = 0
    private var overlay: FocusOverlayView?

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
      return .bottom
    }

    override var prefersStatusBarHidden: Bool {
        return fullScreen
    }

    init(manga: Manga, dataSource: MangaDataSourceable, delegate: MangaViewControllerDelegate, firstTime: Bool = false) {
        self.manga = manga
        self.dataSource = dataSource
        self.delegate = delegate
        self.firstTime = firstTime
        super.init(nibName: nil, bundle: nil)
        dataSource.delegate = self
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
        configureProgressBar()
        configureKeyboard()
        configureGestures()
        configureMenuActions()

        if !firstTime {
            startAtFullScreen()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Navigation bar is hidden for the opening animation, but if fullscreen is false it should be shown
        navigationController?.setNavigationBarHidden(fullScreen, animated: true)

        if firstTime {
            configureOverlay()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlay?.layoutSubviews()
    }

    private func configureNavBar() {
        title = manga.name
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton

        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))
        let ocrButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass.circle"), style: .plain, target: self, action: #selector(toggleOcr))

        ocrActivityIndicator.hidesWhenStopped = true
        let ocrLoadingNavButton = UIBarButtonItem(customView: ocrActivityIndicator)
        navigationItem.rightBarButtonItems = [ocrButton, settingsButton, ocrLoadingNavButton]
    }

    private func createPageController() {
        let orientation: UIInterfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .portrait

        let (spineLocation, initialPages) = dataSource.initialConfiguration(with: orientation, startingPage: Int(manga.currentPage), delegate: self)
        pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.spineLocation: spineLocation.rawValue])
        pageController.isDoubleSided = spineLocation == .mid
        pageController.delegate = self
        pageController.dataSource = dataSource
        pageController.setViewControllers(initialPages, direction: .forward, animated: true, completion: nil)
    }

    private func configureSelectionView() {
        view.addSubview(selectionView)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.isHidden = true
        selectionView.delegate = self
        selectionView.addConstraintsTo(view)
    }

    private func configurePageControllerConstraints() {
        view.addSubview(pageController.view)
        view.sendSubviewToBack(pageController.view)
        addChild(pageController)

        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.view.addConstraintsTo(view)
    }

    private func configureJapaneseHelpView() {
        japaneseHelp.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(japaneseHelp)
        view.addSubview(japaneseHelp.view)
        japaneseHelp.didMove(toParent: self)

        (_, _, japaneseHelpBottomConstraint, _) = japaneseHelp.view.addConstraintsTo(view, sides: [.horizontal, .bottom])
        let topConstraint = japaneseHelp.view.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor)
        topConstraint.priority = .required
        japaneseHelpBottomConstraint.priority = .defaultLow
        topConstraint.isActive = true

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(pan:)))
        edgePan.edges = .bottom
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)
    }

    private func configureProgressBar() {
        view.addSubview(progressBar)
        progressBar.minimumTrackTintColor = .gray
        progressBar.maximumTrackTintColor = .orange
        progressBar.thumbTintColor = .darkGray
        progressBar.minimumValue = 0
        progressBar.maximumValue = Float(manga.totalPages) - 0.001
        progressBar.value = progressBar.maximumValue - Float(manga.currentPage)
        oldPageValue = Int(manga.currentPage)
        if pageController.isDoubleSided {
            oldPageValue -= oldPageValue % 2
        }
        progressBar.alpha = fullScreen ? 0 : 1
        progressBar.addTarget(self, action: #selector(movePage), for: .valueChanged)

        progressBar.translatesAutoresizingMaskIntoConstraints = false

        progressBar.addConstraintsTo(view, sides: .horizontal, spacing: .init(left: 20, right: -20))
        progressBar.bottomAnchor.constraint(equalTo: japaneseHelp.view.topAnchor, constant: -10).isActive = true
    }

    private func configureKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    private func configureGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        view.addGestureRecognizer(longPressGesture)
    }

    func reloadPageController() {
        pageController.removeFromParent()
        pageController.view.removeFromSuperview()
        createPageController()
        configurePageControllerConstraints()
    }

    private func configureOverlay() {
        let ocrButtonView = (navigationItem.rightBarButtonItems?.first?.value(forKey: "view") as? UIView) ?? UIView(frame: .zero)
        let overlay = FocusOverlayView(delegate: self, centerOn: ocrButtonView, circleRadius: 50)
        // Add overlay to window rootViewController, this way is on top of the navigationBar
        if let window = UIApplication.shared.windows.first, let view = window.rootViewController?.view {
            view.addSubview(overlay)
            overlay.translatesAutoresizingMaskIntoConstraints = false

            overlay.addConstraintsTo(view)
            overlay.layer.zPosition = 100
            overlay.alpha = 0
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Tap to toggle\nOCR"
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 35)
            label.textColor = .white
            overlay.addSubview(label)

            label.addConstraintsTo(overlay, sides: [.top, .right], spacing: .init(top: 40, right: -100))
            UIView.animate(withDuration: 0.3, animations: {
                overlay.alpha = 1
            }, completion: { _ in
                // Make sure overlay is the top most view.
                // Without this after the navigationBar ends animating is set as the top view.
                view.bringSubviewToFront(overlay)
            })

            self.overlay = overlay
        }
    }

    private func configureMenuActions() {
        let item = UIMenuItem(title: "Search in Dictionary", action: Selector(("lookup:")))
        UIMenuController.shared.menuItems = [item]
    }

    private func startAtFullScreen() {
        fullScreen = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        setNeedsStatusBarAppearanceUpdate()
        japaneseHelpBottomConstraint.constant = 100
        progressBar.alpha = 0
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

        UIView.animate(withDuration: 0.15) {
            self.progressBar.alpha = self.fullScreen ? 0 : 1
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
        delegate?.back(self)
    }

    @objc func toggleOcr() {
        ocrEnabled = !ocrEnabled
        selectionView.isHidden = !selectionView.isHidden
        if fullScreen != ocrEnabled {
            toggleFullscreen()
        }
    }

    @objc func openSettings() {
        delegate?.didTapSettings(self)
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

    @objc func movePage() {
        var page = Int(floor(progressBar.maximumValue - progressBar.value))
        let orientation: UIInterfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .portrait

        if pageController.isDoubleSided {
            page -= page % 2
        }
        guard page != oldPageValue else { return }

        let (_, pages) = dataSource.initialConfiguration(with: orientation, startingPage: page, delegate: self, fullScreen: fullScreen)

        pageController.setViewControllers(pages, direction: page > oldPageValue ? .reverse : .forward, animated: true, completion: nil)
        delegate?.pageDidChange(self, manga: manga, newPage: pages[0].pageNumber)
        oldPageValue = page
    }

    func isValidTap(_ tap: UILongPressGestureRecognizer) -> Bool {
        guard tap.state == .began &&
                !ocrEnabled,
              let subview = view.hitTest(tap.location(in: view), with: nil),
              subview.isDescendant(of: pageController.view) else {
            return false
        }
        return true
    }

    @objc func longPress(tap: UILongPressGestureRecognizer) {
        guard isValidTap(tap) else { return }
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.01
        animation.autoreverses = true
        animation.duration = 0.1

        view.layer.add(animation, forKey: nil)
        toggleOcr()
    }
}

// MARK: PageViewControllerDelegate
extension MangaViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        guard orientation != .unknown else {
            return pageViewController.spineLocation
        }
        isPageAnimating = false
        let (spineLocation, initialPages) = dataSource.initialConfiguration(with: orientation, and: pageViewController.viewControllers, startingPage: Int(manga.currentPage), delegate: self)

        pageViewController.setViewControllers(initialPages, direction: .forward, animated: true, completion: nil)
        pageViewController.isDoubleSided = spineLocation == .mid

        return spineLocation
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let pageView = pageViewController.viewControllers?.first as? PageViewController, !pageView.isPaddingPage {
            delegate?.pageDidChange(self, manga: manga, newPage: pageView.pageNumber)

            progressBar.value = progressBar.maximumValue - Float(pageView.pageNumber)
            oldPageValue = pageView.pageNumber
            if pageController.isDoubleSided {
                oldPageValue -= oldPageValue % 2
            }
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
        delegate?.didTapPage(self, pageViewController: pageViewController)
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
        delegate?.didSelectSectionOfImage(self, image: image)
    }
}

extension MangaViewController: JapaneseHelpViewControllerDelegate {
    func handlePan(_ japaneseHelpViewController: JapaneseHelpViewController, pan: UIPanGestureRecognizer) {
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

    func didOpenDictionary(_ japaneseHelpViewController: JapaneseHelpViewController) {
        if japaneseHelpBottomConstraint.constant != 0 {
            japaneseHelpBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func createAnkiCard(_ japaneseHelpViewController: JapaneseHelpViewController, sentence: String, term: SearchTermResult) {
        guard let pages = pageController.viewControllers as? [PageViewController] else { return }
        let images = pages.compactMap(\.pageImage)
        let imageWidth = images.map(\.size.width)
            .reduce(0, +)
        let imageHeight = images.map(\.size.height).max() ?? 0

        guard imageWidth > 0 && imageHeight > 0 else { return }

        let renderer = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight)))
        let image = renderer.image { context in
            for image in images {
                image.draw(at: .zero)
                context.cgContext.translateBy(x: image.size.width, y: 0)
            }
        }

        delegate?.didTapCreateAnkiCard(self, image: image, sentence: sentence, dictionaryResult: term)
    }
}

extension MangaViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MangaViewController: MangaDataSourceDelegate {
    func shouldLoadPage(_ mangaDataSource: MangaDataSourceable) -> Bool {
        return !(isPageAnimating || ocrEnabled)
    }
}

extension MangaViewController: FocusOverlayViewDelegate {
    func didTouchOutside(_ focusOverlayView: FocusOverlayView) {
        UIView.animate(withDuration: 0.3) {
            focusOverlayView.alpha = 0
        } completion: { _ in
            focusOverlayView.removeFromSuperview()
        }
    }

    func didInteractWithContent(_ focusOverlayView: FocusOverlayView) {
        toggleOcr()
        UIView.animate(withDuration: 0.3) {
            focusOverlayView.alpha = 0
        } completion: { _ in
            focusOverlayView.removeFromSuperview()
        }
    }
}
