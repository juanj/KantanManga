//
//  OpenCollectionAnimationController.swift
//  Kantan-Manga
//
//  Created by Juan on 19/09/20.
//

import UIKit

class OpenCollectionAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let operation: UINavigationController.Operation
    private let collectionIndexPath: IndexPath

    init(operation: UINavigationController.Operation, indexPath: IndexPath) {
        self.operation = operation
        collectionIndexPath = indexPath
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if operation == .push {
            pushAnimation(transitionContext)
        } else {
            popAnimation(transitionContext)
        }
    }

    private func pushAnimation(_ context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from) as? LibraryViewController,
            let toVC = context.viewController(forKey: .to) as? CollectionViewController else { return }

        // TODO: Rotation
        let containerView = context.containerView
        containerView.addSubview(toVC.view)
        let oldColor = toVC.view.backgroundColor
        toVC.view.backgroundColor = .clear

        fromVC.collectionView.cellForItem(at: collectionIndexPath)?.alpha = 0

        let duration = transitionDuration(using: context)
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                toVC.view.backgroundColor = oldColor
            }
        }, completion: { _ in
            fromVC.collectionView.cellForItem(at: self.collectionIndexPath)?.alpha = 1
            fromVC.view.alpha = 1
            toVC.animating = false
            context.completeTransition(!context.transitionWasCancelled)
        })
    }

    private func popAnimation(_ context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from) as? CollectionViewController,
            let toVC = context.viewController(forKey: .to) as? LibraryViewController else { return }

        let containerView = context.containerView
        containerView.addSubview(toVC.view)
        containerView.bringSubviewToFront(fromVC.view)
        fromVC.view.alpha = 1
        toVC.view.alpha = 1

        // LibraryViewController is reloaded on apper, so the selection is lost.
        // Insetad use this property to start a cell with alpha 0
        toVC.hideIndexPath = collectionIndexPath

        let duration = transitionDuration(using: context)
        fromVC.closeAnimation(duration: duration)
        UIView.animate(withDuration: duration, animations: {
            toVC.view.alpha = 1
            fromVC.view.backgroundColor = .clear
            if let cell = toVC.collectionView.cellForItem(at: self.collectionIndexPath) as? MangaCollectionCollectionViewCell {
                cell.nameLabel.alpha = 1
            }
        }, completion: { _ in
            if let cell = toVC.collectionView.cellForItem(at: self.collectionIndexPath) as? MangaCollectionCollectionViewCell {
                cell.imageViews.forEach { $0.alpha = 1 }
            }
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}
