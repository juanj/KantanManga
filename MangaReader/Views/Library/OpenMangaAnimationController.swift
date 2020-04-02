//
//  OpenMangaAnimationController.swift
//  MangaReader
//
//  Created by Juan on 2/04/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation


class OpenMangaAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    private let mangaCover: UIImage

    init(originFrame: CGRect, mangaCover: UIImage) {
      self.originFrame = originFrame
        self.mangaCover = mangaCover
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? LibraryViewController,
            let toVC = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        containerView.addSubview(toVC.view)
        toVC.view.alpha = 0

        let imageView = UIImageView(image: mangaCover)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = originFrame

        containerView.addSubview(imageView)

        if let indexPath = fromVC.collectionView.indexPathsForSelectedItems?.first {
            fromVC.collectionView.cellForItem(at: indexPath)?.alpha = 0
        }

        let duration = transitionDuration(using: transitionContext)
        UIView.animateKeyframes(
          withDuration: duration,
          delay: 0,
          options: .calculationModeCubic,
          animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 3/4) {
                imageView.frame = finalFrame
            }
            UIView.addKeyframe(withRelativeStartTime: 3/4, relativeDuration: 1/4) {
                imageView.alpha = 0
                toVC.view.alpha = 1
            }
        },
          completion: { _ in
            toVC.view.isHidden = false
            imageView.removeFromSuperview()
            fromVC.view.layer.transform = CATransform3DIdentity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
