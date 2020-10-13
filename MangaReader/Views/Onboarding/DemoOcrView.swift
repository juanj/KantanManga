//
//  DemoOcrView.swift
//  Kantan-Manga
//
//  Created by Juan on 13/10/20.
//

import UIKit

class DemoOcrView: UIView {
    private var shapeLayer: CAShapeLayer!
    // Create a view to hold the animations and be able to clip the content
    private var container: UIView!
    private var animating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        configureContainer()
        addImage()
    }

    func startAnimation() {
        // Prevent multiple animations form running at the same time
        if !animating {
            animating = true
            selectionAnimation()
        }
    }

    private func configureContainer() {
        container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .blue
        container.clipsToBounds = true
        container.layer.masksToBounds = true

        addSubview(container)

        container.topAnchor.constraint(equalTo: topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        container.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    private func addImage() {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "demo-ocr")
        container.addSubview(image)
        image.widthAnchor.constraint(equalTo: image.heightAnchor).isActive = true
        image.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
    }

    private func selectionAnimation() {
        if shapeLayer != nil {
            shapeLayer.removeFromSuperlayer()
        }
        let topPoint = CGPoint(x: frame.width / 8, y: frame.width / 4)
        shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(rect: CGRect(origin: topPoint, size: .zero)).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineDashPattern = [10, 5]
        container.layer.addSublayer(shapeLayer)

        let sizeAnimation = CABasicAnimation(keyPath: "path")
        sizeAnimation.fromValue = shapeLayer.path
        sizeAnimation.toValue = UIBezierPath(rect: CGRect(origin: topPoint, size: CGSize(width: topPoint.x + container.frame.width / 3.2, height: container.frame.height / 1.6))).cgPath
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
        loaderView.frame.size.width = container.frame.width / 5
        loaderView.frame.size.height = container.frame.width / 5
        loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loaderView.layer.cornerRadius = 15
        container.addSubview(loaderView)

        loaderView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        loaderView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2).isActive = true
        loaderView.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2).isActive = true

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
        let parsedView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        parsedView.translatesAutoresizingMaskIntoConstraints = false
        parsedView.backgroundColor = .clear

        container.addSubview(parsedView)

        parsedView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.37).isActive = true
        parsedView.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        parsedView.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        let bottomConstraint = parsedView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: container.frame.height * 0.37)
        bottomConstraint.isActive = true

        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "ここ  押される  と  超  痛い"
        textLabel.numberOfLines = 0
        textLabel.textColor = .black

        parsedView.contentView.addSubview(textLabel)

        textLabel.centerYAnchor.constraint(equalTo: parsedView.centerYAnchor).isActive = true
        let padding = container.frame.height * 0.05
        textLabel.widthAnchor.constraint(equalToConstant: container.frame.width - padding*2).isActive = true
        textLabel.leftAnchor.constraint(equalTo: parsedView.leftAnchor, constant: padding).isActive = true
        textLabel.rightAnchor.constraint(equalTo: parsedView.rightAnchor, constant: -padding).isActive = true

        textLabel.font = .systemFont(ofSize: container.frame.height * 0.1, weight: .bold)

        layoutIfNeeded()
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }, completion: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.5, animations: {
                    parsedView.alpha = 0
                }, completion: { _ in
                    parsedView.removeFromSuperview()
                    self.animating = false
                    self.startAnimation()
                })
            }
        })

    }
}

extension DemoOcrView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        loadingAnimation()
    }
}
