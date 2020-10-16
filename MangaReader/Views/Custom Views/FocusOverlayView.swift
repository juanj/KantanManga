//
//  FocusOverlayView.swift
//  Kantan-Manga
//
//  Created by Juan on 16/10/20.
//

import UIKit

protocol FocusOverlayViewDelegate: AnyObject {
    func didTouchOutside(_ focusOverlayView: FocusOverlayView)
    func didInteractWithContent(_ focusOverlayView: FocusOverlayView)
}

class FocusOverlayView: UIView {
    var circleCenter: CGPoint = .zero {
        didSet {
            refreshOverlay()
        }
    }
    var circleRadius: CGFloat = 100 {
        didSet {
            refreshOverlay()
        }
    }
    var overlayColor: CGColor = UIColor.gray.withAlphaComponent(0.5).cgColor {
        didSet {
            overlayLayer.fillColor = overlayColor
        }
    }

    weak var delegate: FocusOverlayViewDelegate?
    private let overlayLayer = CAShapeLayer()

    init(delegate: FocusOverlayViewDelegate, circleCenter: CGPoint, circleRadius: CGFloat) {
        self.delegate = delegate
        self.circleCenter = circleCenter
        self.circleRadius = circleRadius
        super.init(frame: .zero)

        layer.addSublayer(overlayLayer)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(trigger))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        refreshOverlay()
    }

    private func pathForOverlay() -> CGPath {
        let path = UIBezierPath(rect: frame)
        let circle = UIBezierPath(ovalIn: CGRect(x: circleCenter.x - circleRadius, y: circleCenter.y - circleRadius, width: circleRadius * 2, height: circleRadius * 2))
        path.append(circle.reversing())
        return path.cgPath
    }

    private func refreshOverlay() {
        overlayLayer.path = pathForOverlay()
        overlayLayer.fillColor = overlayColor
    }

    @objc private func trigger(tapGesture: UITapGestureRecognizer) {
        let touch = tapGesture.location(in: self)
        let term1 = pow(touch.x - circleCenter.x, 2) / pow(circleRadius, 2)
        let term2 = pow(touch.y - circleCenter.y, 2) / pow(circleRadius, 2)
        if term1 + term2 <= 1 {
            delegate?.didInteractWithContent(self)
            // TODO: Pass event down
        } else {
            delegate?.didTouchOutside(self)
        }
    }
}
