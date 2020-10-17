//
//  DemoOcrView.swift
//  Kantan-Manga
//
//  Created by Juan on 13/10/20.
//

import UIKit

class DemoOcrView: UIView {
    // Create a view to hold the animations and be able to clip the content
    private var container: UIView!
    private var shapeLayer: CAShapeLayer?
    private var parsedView: UIVisualEffectView?
    private var parsedViewBottomConstraint: NSLayoutConstraint?
    private var touchView: UIView?
    private var touchViewTopConstraint: NSLayoutConstraint?
    private var touchViewLeftConstraint: NSLayoutConstraint?
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
            selectionTouchAnimation()
        }
    }

    private func configureContainer() {
        container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .blue
        container.clipsToBounds = true
        container.layer.masksToBounds = true
        addSubview(container)
        container.addConstraintsTo(self)
    }

    private func addImage() {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "demo-ocr")
        container.addSubview(image)
        image.widthAnchor.constraint(equalTo: image.heightAnchor).isActive = true
        image.addConstraintsTo(container)
    }

    private func selectionAnimation() {
        if shapeLayer != nil {
            shapeLayer?.removeFromSuperlayer()
        }
        let topPoint = CGPoint(x: frame.width / 8, y: frame.width / 4)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(rect: CGRect(origin: topPoint, size: .zero)).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineDashPattern = [10, 5]
        container.layer.addSublayer(shapeLayer)

        let sizeAnimation = CABasicAnimation(keyPath: "path")
        sizeAnimation.fromValue = shapeLayer.path
        sizeAnimation.toValue = UIBezierPath(rect: CGRect(origin: topPoint, size: CGSize(width: container.frame.width / 2.4, height: container.frame.height / 1.6))).cgPath
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

        self.shapeLayer = shapeLayer
    }

    private func selectionTouchAnimation() {
        let touchView = CircleView()
        touchView.layer.zPosition = 5
        touchView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        touchView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(touchView)

        let width = container.frame.width / 10
        let height = container.frame.height / 10
        let startLocation = CGPoint(x: container.frame.width / 8, y: container.frame.width / 4)
        touchView.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.1).isActive = true
        touchView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.1).isActive = true

        let (touchViewTopConstraint, touchViewLeftConstraint, _, _) = touchView.addConstraintsTo(container, sides: [.top, .left], spacing: .init(top: startLocation.y - height / 2, left: startLocation.x - width / 2))

        let endLocation = CGPoint(x: startLocation.x + container.frame.width / 2.4 - width / 2, y: startLocation.y + container.frame.height / 1.6 - height / 2)

        layoutIfNeeded()

        touchViewTopConstraint?.constant = endLocation.y
        touchViewLeftConstraint?.constant = endLocation.x

        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: { (_) in })

        self.touchView = touchView
        self.touchViewTopConstraint = touchViewTopConstraint
        self.touchViewLeftConstraint = touchViewLeftConstraint
    }

    private func loadingAnimation() {
        let loaderView = UIView()
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.frame.size.width = container.frame.width / 5
        loaderView.frame.size.height = container.frame.width / 5
        loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loaderView.layer.cornerRadius = 15
        container.addSubview(loaderView)

        loaderView.addCenterConstraintsTo(container)
        loaderView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2).isActive = true
        loaderView.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2).isActive = true

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loaderView.addSubview(activityIndicator)

        activityIndicator.addCenterConstraintsTo(loaderView)

        activityIndicator.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            loaderView.removeFromSuperview()
            self.shapeLayer?.removeFromSuperlayer()
            self.textAnimation()
        }
    }

    private func textAnimation() {
        let parsedView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        parsedView.translatesAutoresizingMaskIntoConstraints = false
        parsedView.backgroundColor = .clear

        container.addSubview(parsedView)

        parsedView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.37).isActive = true
        let (_, _, parsedViewBottomConstraint, _) = parsedView.addConstraintsTo(container, sides: [.horizontal, .bottom], spacing: .init(bottom: container.frame.height * 0.37))

        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "ここ  押される  と  超  痛い"
        textLabel.numberOfLines = 0
        textLabel.textColor = .black

        parsedView.contentView.addSubview(textLabel)

        let padding = container.frame.height * 0.05
        textLabel.centerYAnchor.constraint(equalTo: parsedView.centerYAnchor).isActive = true
        textLabel.widthAnchor.constraint(equalToConstant: container.frame.width - padding*2).isActive = true
        textLabel.addConstraintsTo(parsedView, sides: .horizontal, spacing: .init(left: padding, right: -padding))

        textLabel.font = .systemFont(ofSize: container.frame.height * 0.1, weight: .bold)

        layoutIfNeeded()
        parsedViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }, completion: { (_) in
            self.selectWordAnimation()
        })

        self.parsedView = parsedView
        self.parsedViewBottomConstraint = parsedViewBottomConstraint
    }

    private func selectWordAnimation() {
        guard let parsedView = parsedView,
              let touchView = touchView else { return }

        let selectedWordLabel = UILabel()
        selectedWordLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedWordLabel.textColor = .white
        selectedWordLabel.text = "超"
        selectedWordLabel.font = .systemFont(ofSize: container.frame.height * 0.1, weight: .bold)

        let selectedWordView = UIView()
        selectedWordView.translatesAutoresizingMaskIntoConstraints = false
        selectedWordView.backgroundColor = .black
        selectedWordView.layer.cornerRadius = container.frame.height / 15

        selectedWordView.addSubview(selectedWordLabel)

        let padding = container.frame.height * 0.04
        selectedWordLabel.addConstraintsTo(selectedWordView, spacing: .init(top: padding / 2, left: padding, bottom: -padding / 2, right: -padding))

        parsedView.contentView.addSubview(selectedWordView)

        selectedWordView.addConstraintsTo(parsedView, sides: [.bottom, .left], spacing: .init(left: container.frame.width / 100, bottom: -container.frame.height / 25))

        selectedWordView.alpha = 0

        layoutIfNeeded()
        let centerPoint = container.convert(selectedWordView.center, from: parsedView.coordinateSpace)
        touchViewLeftConstraint?.constant = centerPoint.x - touchView.frame.width / 2
        touchViewTopConstraint?.constant = centerPoint.y - touchView.frame.height / 2

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: {_ in
            selectedWordView.alpha = 1
            touchView.removeFromSuperview()
            self.touchView = nil
            self.dictionaryAnimation()
        })
    }

    private func dictionaryAnimation() {
        guard let parsedViewBottomConstraint = parsedViewBottomConstraint,
              let parsedView = parsedView else { return }

        let titleLabel = UILabel()
        titleLabel.text = "超, ちょう, チョー"
        titleLabel.font = .systemFont(ofSize: container.frame.width / 19, weight: .bold)

        let meaningLabel = UILabel()
        meaningLabel.font = .systemFont(ofSize: container.frame.width / 20)
        meaningLabel.numberOfLines = 3
        meaningLabel.text = "• super-; ultra-; hyper-; extreme\n• extremely; really; totally; absolutely\n• over; more than"

        let stackView = UIStackView(arrangedSubviews: [titleLabel, meaningLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading

        let dictView = UIView()
        dictView.backgroundColor = .systemBackground
        dictView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dictView)

        dictView.addSubview(stackView)

        let padding = container.frame.width / 20
        stackView.addConstraintsTo(dictView, spacing: .init(top: padding, left: padding, bottom: -padding, right: -padding))

        dictView.heightAnchor.constraint(equalTo: parsedView.heightAnchor).isActive = true

        let (_, _, dictBottomConstraint, _) = dictView.addConstraintsTo(container, sides: [.horizontal, .bottom], spacing: .init(bottom: parsedView.frame.height))
        layoutIfNeeded()

        parsedViewBottomConstraint.constant = -parsedView.frame.height
        dictBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 2, animations: {
                parsedView.alpha = 0
                dictView.alpha = 0
            }, completion: { _ in
                parsedView.removeFromSuperview()
                self.animating = false
                self.startAnimation()
            })
        })
    }
}

extension DemoOcrView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        loadingAnimation()
    }
}
