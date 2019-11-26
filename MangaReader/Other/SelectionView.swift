//
//  SelectionView.swift
//  MangaReader
//
//  Created by Juan on 26/11/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol SelectionViewDelegate: AnyObject {
    func didSelectSection(_ selectionView: SelectionView, section: CGRect)
}

class SelectionView: UIView {
    var startPoint: CGPoint!
    var shapeLayer: CAShapeLayer!
    weak var delegate: SelectionViewDelegate!

    convenience init (frame: CGRect, delegate: SelectionViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isOpaque = false
        self.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.startPoint = touch.location(in: self)

            self.shapeLayer = CAShapeLayer()
            self.shapeLayer.lineWidth = 5.0
            self.shapeLayer.fillColor = UIColor.clear.cgColor
            self.shapeLayer.strokeColor = UIColor.red.cgColor
            self.shapeLayer.lineDashPattern = [10, 5]

            self.layer.addSublayer(self.shapeLayer)

            var dashAnimation = CABasicAnimation()
            dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            dashAnimation.duration = 0.75
            dashAnimation.fromValue = 0.0
            dashAnimation.toValue = 15.0
            dashAnimation.repeatCount = .infinity
            self.shapeLayer.add(dashAnimation, forKey: "linePhase")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            let path = CGMutablePath()
            path.move(to: self.startPoint)
            path.addLine(to: CGPoint(x: self.startPoint.x, y: point.y))
            path.addLine(to: point)
            path.addLine(to: CGPoint(x: point.x, y: self.startPoint.y))
            path.closeSubpath()
            self.shapeLayer.path = path
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.shapeLayer.isHidden = true
        if let touch = touches.first {
            let endPoint = touch.location(in: self)
            self.delegate?.didSelectSection(self, section: CGRect(x: min(self.startPoint.x, endPoint.x), y: min(self.startPoint.y, endPoint.y), width: abs(self.startPoint.x - endPoint.x), height: abs(self.startPoint.y - endPoint.y)))
        }
    }

    func reset() {
        if self.shapeLayer != nil {
            self.shapeLayer.removeFromSuperlayer()
            self.shapeLayer = nil
        }
    }
}
