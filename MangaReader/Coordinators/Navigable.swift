//
//  Navigable.swift
//  Kantan-Manga
//
//  Created by Juan on 7/11/20.
//

import Foundation
import UIKit

protocol Navigable: UIViewController {
    var delegate: UINavigationControllerDelegate? { get set }
    var viewControllers: [UIViewController] { get }
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    @discardableResult
    func popViewController(animated: Bool) -> UIViewController?
    func present(_ viewController: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
    func setNavigationBarHidden(_ hidden: Bool, animated: Bool)
    @discardableResult
    func popToRootViewController(animated: Bool) -> [UIViewController]?
}

extension UINavigationController: Navigable {}
