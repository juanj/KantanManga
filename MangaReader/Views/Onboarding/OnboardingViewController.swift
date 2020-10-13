//
//  OnboardingViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 10/10/20.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ocrDemoContainer: UIView!

    private var shapeLayer: CAShapeLayer!
    private var animating = false
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
    }

    private func startAnimation() {
        selectionAnimation()
    }

    private func selectionAnimation() {
        if shapeLayer != nil {
            shapeLayer.removeFromSuperlayer()
        }
        let topPoint = CGPoint(x: ocrDemoContainer.frame.width / 8, y: ocrDemoContainer.frame.width / 4)
        shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(rect: CGRect(origin: topPoint, size: .zero)).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineDashPattern = [10, 5]
        ocrDemoContainer.layer.addSublayer(shapeLayer)

        let sizeAnimation = CABasicAnimation(keyPath: "path")
        sizeAnimation.fromValue = shapeLayer.path
        sizeAnimation.toValue = UIBezierPath(rect: CGRect(origin: topPoint, size: CGSize(width: topPoint.x + ocrDemoContainer.frame.width / 3.2, height: ocrDemoContainer.frame.height / 1.6))).cgPath
        sizeAnimation.duration = 1
        sizeAnimation.fillMode = .forwards
        sizeAnimation.isRemovedOnCompletion = false
        sizeAnimation.timingFunction = .init(name: .easeInEaseOut)
        sizeAnimation.delegate = self

        shapeLayer.add(sizeAnimation, forKey: "sizeAnimation")

        var dashAnimation = CABasicAnimation()
        dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.duration = 0.75
        dashAnimation.fromValue = 0.0
        dashAnimation.toValue = 15.0
        dashAnimation.repeatCount = .infinity
        shapeLayer.add(dashAnimation, forKey: "linePhase")
    }

    private func loadingAnimation() {
        let loaderView = UIView()
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.frame.size.width = ocrDemoContainer.frame.width / 5
        loaderView.frame.size.height = ocrDemoContainer.frame.width / 5
        loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loaderView.layer.cornerRadius = 15
        ocrDemoContainer.addSubview(loaderView)

        loaderView.centerYAnchor.constraint(equalTo: ocrDemoContainer.centerYAnchor).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: ocrDemoContainer.centerXAnchor).isActive = true
        loaderView.widthAnchor.constraint(equalTo: ocrDemoContainer.widthAnchor, multiplier: 0.2).isActive = true
        loaderView.heightAnchor.constraint(equalTo: ocrDemoContainer.widthAnchor, multiplier: 0.2).isActive = true

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loaderView.addSubview(activityIndicator)

        activityIndicator.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor).isActive = true

        activityIndicator.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            loaderView.removeFromSuperview()
            self.shapeLayer.removeFromSuperlayer()
            self.textAnimation()
        }
    }

    private func textAnimation() {
        let container = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear

        ocrDemoContainer.addSubview(container)

        container.heightAnchor.constraint(equalTo: ocrDemoContainer.heightAnchor, multiplier: 0.37).isActive = true
        container.leftAnchor.constraint(equalTo: ocrDemoContainer.leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: ocrDemoContainer.rightAnchor).isActive = true
        let bottomConstraint = container.bottomAnchor.constraint(equalTo: ocrDemoContainer.bottomAnchor, constant: ocrDemoContainer.frame.height * 0.37)
        bottomConstraint.isActive = true

        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "ここ  押される  と  超  痛い"
        textLabel.numberOfLines = 0
        textLabel.textColor = .black

        container.contentView.addSubview(textLabel)

        textLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        let padding = ocrDemoContainer.frame.height * 0.05
        textLabel.widthAnchor.constraint(equalToConstant: ocrDemoContainer.frame.width - padding*2).isActive = true
        textLabel.leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding).isActive = true
        textLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding).isActive = true

        textLabel.font = .systemFont(ofSize: ocrDemoContainer.frame.height * 0.1, weight: .bold)

        view.layoutIfNeeded()
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.5, animations: {
                    container.alpha = 0
                }, completion: { _ in
                    container.removeFromSuperview()
                    self.startAnimation()
                })
            }
        })

    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = min(round(scrollView.contentOffset.x / scrollView.frame.width), 3)
        pageControl.currentPage = Int(page)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = min(round(scrollView.contentOffset.x / scrollView.frame.width), 3)
        if !animating && page == 1 {
            animating = true
            startAnimation()
        }
    }
}

extension OnboardingViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        loadingAnimation()
    }
}
