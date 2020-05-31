//
//  MockNavigationController.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import MangaReader

class MockNavigationController: UINavigationController {
    var presentedViewControllerTest: UIViewController?
    var popCalled = false
    var pushCalled = false
    var dismissCalled = false
    var viewControllersTest = [UIViewController]()

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewControllerTest = viewControllerToPresent
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        popCalled = true
        _ = viewControllers.popLast()
        return nil
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushCalled = true
        viewControllersTest.append(viewController)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewControllersTest = viewControllers
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
    }
}
