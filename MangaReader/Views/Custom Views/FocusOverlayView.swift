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
    var centerOn: UIView {
        didSet {
            refreshOverlay()
        }
    }
    var circleRadius: CGFloat = 50 {
        didSet {
            refreshOverlay()
        }
    }
    var overlayColor: CGColor = UIColor.black.withAlphaComponent(0.7).cgColor {
        didSet {
            overlayLayer.fillColor = overlayColor
        }
    }

    weak var delegate: FocusOverlayViewDelegate?
    private let overlayLayer = CAShapeLayer()

    init(delegate: FocusOverlayViewDelegate, centerOn view: UIView, circleRadius: CGFloat) {
        self.delegate = delegate
        centerOn = view
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
        superview?.layoutIfNeeded()
        refreshOverlay()
    }

    private func pathForOverlay() -> CGPath {
        guard let circleCenter = centerOn.superview?.convert(centerOn.center, to: self) else {
            return CGPath(rect: .zero, transform: nil)
        }
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
        guard let circleCenter = centerOn.superview?.convert(centerOn.center, to: self) else { return }
        let touch = tapGesture.location(in: self)
        let term1 = pow(touch.x - circleCenter.x, 2) / pow(circleRadius, 2)
        let term2 = pow(touch.y - circleCenter.y, 2) / pow(circleRadius, 2)
        if term1 + term2 <= 1 {
            delegate?.didInteractWithContent(self)
        } else {
            delegate?.didTouchOutside(self)
        }
    }
}
