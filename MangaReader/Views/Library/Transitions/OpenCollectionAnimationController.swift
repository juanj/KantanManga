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
        toVC.fadeImages = fromVC.collectionView.indexPathsForVisibleItems.count > 0 && fromVC.collectionView.indexPathsForVisibleItems.firstIndex(of: IndexPath(item: 0, section: 0)) == nil
        toVC.view.layoutIfNeeded()

        let duration = transitionDuration(using: context)
        var sourcePoint = toVC.collectionView.collectionViewLayout.layoutAttributesForItem(at: collectionIndexPath)?.center ?? .zero
        sourcePoint.y -= toVC.collectionView.contentOffset.y + toVC.collectionView.contentInset.top
        fromVC.closeAnimation(duration: duration, toPoint: sourcePoint)
        UIView.animate(withDuration: duration, animations: {
            toVC.view.alpha = 1
            fromVC.view.backgroundColor = .clear
        }, completion: { _ in
            if let cell = toVC.collectionView.cellForItem(at: self.collectionIndexPath) as? MangaCollectionCollectionViewCell {
                cell.imageViews.forEach { $0.alpha = 1 }
            }
            toVC.hideIndexPath = nil
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}
