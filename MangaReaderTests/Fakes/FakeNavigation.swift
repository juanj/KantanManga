//
//  FakeNavigation.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class FakeNavigation: UIViewController, Navigable {
    weak var delegate: UINavigationControllerDelegate?
    var viewControllers = [UIViewController]()
    override var presentedViewController: UIViewController? {
        get {
            return lastPresented
        }
        set {
            lastPresented = newValue
        }
    }
    var navigationBarHidden = false

    private var lastPresented: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        lastPresented = viewControllerToPresent
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

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        lastPresented = nil
    }

    func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        navigationBarHidden = hidden
    }

    func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let viewControllers = self.viewControllers
        self.viewControllers = []
        return viewControllers
    }
}
