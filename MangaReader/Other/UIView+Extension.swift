//
//  UIView+Extension.swift
//  Kantan-Manga
//
//  Created by Juan on 17/10/20.
//

import UIKit

extension UIView {
    struct Sides: OptionSet {
        let rawValue: Int

        static let top = Sides(rawValue: 1 << 0)
        static let left = Sides(rawValue: 1 << 1)
        static let bottom = Sides(rawValue: 1 << 2)
        static let right = Sides(rawValue: 1 << 3)

        static let all: Sides = [.top, .left, .bottom, .right]
        static let vertical: Sides = [.top, .bottom]
        static let horizontal: Sides = [.left, .right]
    }

    struct Spacing {
        let top: CGFloat
        let left: CGFloat
        let bottom: CGFloat
        let right: CGFloat

        init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
            self.top = top
            self.left = left
            self.bottom = bottom
            self.right = right
        }
    }

    // We want to return a tuple here to allow unpacking
    // swiftlint:disable:next large_tuple
    @discardableResult func addConstraintsTo(_ otherView: UIView, sides: Sides = .all, spacing: Spacing = Spacing()) -> (top: NSLayoutConstraint?, left: NSLayoutConstraint?, bottom: NSLayoutConstraint?, right: NSLayoutConstraint?) {
        var topConstraint, leftConstraint, bottomConstraint, rightConstraint: NSLayoutConstraint?
        if sides.contains(.top) {
            topConstraint = topAnchor.constraint(equalTo: otherView.topAnchor, constant: spacing.top)
            topConstraint?.isActive = true
        }
        if sides.contains(.left) {
            leftConstraint = leftAnchor.constraint(equalTo: otherView.leftAnchor, constant: spacing.left)
            leftConstraint?.isActive = true
        }
        if sides.contains(.bottom) {
            bottomConstraint = bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: spacing.bottom)
            bottomConstraint?.isActive = true
        }
        if sides.contains(.right) {
            rightConstraint = rightAnchor.constraint(equalTo: otherView.rightAnchor, constant: spacing.right)
            rightConstraint?.isActive = true
        }

        return (topConstraint, leftConstraint, bottomConstraint, rightConstraint)
    }

    @discardableResult func addCenterConstraintsTo(_ otherView: UIView, offset: CGPoint = .zero) -> (centerX: NSLayoutConstraint, centerY: NSLayoutConstraint) {
        let centerXConstraint = centerXAnchor.constraint(equalTo: otherView.centerXAnchor, constant: offset.x)
        let centerYConstraint = centerYAnchor.constraint(equalTo: otherView.centerYAnchor, constant: offset.y)

        centerXConstraint.isActive = true
        centerYConstraint.isActive = true

        return (centerXConstraint, centerYConstraint)
    }
}
