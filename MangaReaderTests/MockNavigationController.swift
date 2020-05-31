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
    var dismissCalled = false

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewControllerTest = viewControllerToPresent
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        popCalled = true
        return nil
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
    }
}
