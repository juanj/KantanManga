//
//  MangaDataSourceable.swift
//  Kantan-Manga
//
//  Created by Juan on 26/11/20.
//

import Foundation

protocol MangaDataSourceable: UIPageViewControllerDataSource {
    var forceToggleMode: Bool { get set }
    var pagesOffset: Bool { get set }
    var pageTextOffset: Int { get set }
    var hidePageLabel: Bool { get set }
    var delegate: MangaDataSourceDelegate? { get set }

    init?(manga: Manga, readerBuilder: (_ path: String, _ completion: @escaping (Reader) -> Void) -> Void)
    func initialConfiguration(with orientation: UIInterfaceOrientation, and viewControllers: [UIViewController]?, startingPage: Int, delegate: PageViewControllerDelegate?, fullScreen: Bool) -> (UIPageViewController.SpineLocation, [PageViewController])
    func createPage(index: Int, side: PageViewController.Side, delegate: PageViewControllerDelegate?, fullScreen: Bool) -> PageViewController
    func nextPage(currentPage: UIViewController) -> UIViewController?
    func previousPage(currentPage: UIViewController) -> UIViewController?
}

// MARK: Default parameters
extension MangaDataSourceable {
    func initialConfiguration(with orientation: UIInterfaceOrientation, and viewControllers: [UIViewController]? = nil, startingPage: Int, delegate: PageViewControllerDelegate? = nil, fullScreen: Bool = true) -> (UIPageViewController.SpineLocation, [PageViewController]) {
        initialConfiguration(with: orientation, and: viewControllers, startingPage: startingPage, delegate: delegate, fullScreen: fullScreen)
    }

    func createPage(index: Int, side: PageViewController.Side = .center, delegate: PageViewControllerDelegate?, fullScreen: Bool = false) -> PageViewController {
        createPage(index: index, side: side, delegate: delegate, fullScreen: fullScreen)
    }
}
