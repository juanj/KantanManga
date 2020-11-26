//
//  FakeMangaDataSource.swift
//  Kantan-MangaTests
//
//  Created by Juan on 26/11/20.
//

@testable import Kantan_Manga

class FakeMangaDataSorce: NSObject, MangaDataSourceable {
    var forceToggleMode = false
    var pagesOffset = false
    var pageTextOffset = 0
    var hidePageLabel = false
    weak var delegate: MangaDataSourceDelegate?

    // MARK: Method calls
    var initialConfigurationCalled = false

    override init() {}

    required init?(manga: Manga, readerBuilder: (String, @escaping (Reader) -> Void) -> Void) {}

    func initialConfiguration(with orientation: UIInterfaceOrientation, and viewControllers: [UIViewController]?, startingPage: Int, delegate: PageViewControllerDelegate?, fullScreen: Bool) -> (UIPageViewController.SpineLocation, [PageViewController]) {
        initialConfigurationCalled = true
        return (.mid, [])
    }

    func createPage(index: Int, side: PageViewController.Side, delegate: PageViewControllerDelegate?, fullScreen: Bool) -> PageViewController {
        return PageViewController(delegate: nil, pageSide: .center, pageNumber: 0)
    }

    func nextPage(currentPage: UIViewController) -> UIViewController? {
        return nil
    }

    func previousPage(currentPage: UIViewController) -> UIViewController? {
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
}
