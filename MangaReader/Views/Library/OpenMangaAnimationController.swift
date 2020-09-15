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
        return 1.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? CollectionViewController,
            let toVC = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        containerView.addSubview(toVC.view)
        toVC.view.alpha = 0

        let imageView = UIImageView(image: mangaCover)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = originFrame

        let overlay = UIView()
        overlay.frame = finalFrame
        overlay.backgroundColor = .black
        overlay.alpha = 0

        containerView.addSubview(overlay)
        containerView.addSubview(imageView)

        if let indexPath = fromVC.collectionView.indexPathsForSelectedItems?.first {
            fromVC.collectionView.cellForItem(at: indexPath)?.alpha = 0
        }

        let duration = transitionDuration(using: transitionContext)

        let animation = UIViewPropertyAnimator(duration: duration * 0.7, curve: .easeOut)
        let secondAnimation = UIViewPropertyAnimator(duration: duration * 0.3, curve: .easeIn)
        animation.addAnimations {
            overlay.alpha = 1
            fromVC.view.alpha = 0
            imageView.frame = finalFrame
        }
        secondAnimation.addAnimations {
            overlay.alpha = 0
            imageView.alpha = 0
        }
        animation.startAnimation()
        animation.addCompletion { (_) in
            toVC.view.alpha = 1
            secondAnimation.startAnimation()
        }
        secondAnimation.addCompletion { (_) in
            fromVC.view.alpha = 1
            imageView.removeFromSuperview()
            overlay.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
