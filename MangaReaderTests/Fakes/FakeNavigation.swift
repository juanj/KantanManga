//
//  FakeNavigation.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class FakeNavigation: Navigable {
    var delegate: UINavigationControllerDelegate?
    var viewControllers = [UIViewController]()
    var presentedViewController: UIViewController?
    var navigationBarHidden = false

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewController = viewControllerToPresent
    }

    func popViewController(animated: Bool) -> UIViewController? {
        let last = viewControllers.popLast()
        return last
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewControllers.append(viewController)
    }

    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        self.viewControllers = viewControllers
    }

    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewController = nil
    }

    func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        navigationBarHidden = hidden
    }
}
