//
//  ConstraintsUtils.swift
//  Kantan-MangaTests
//
//  Created by Juan on 26/11/20.
//

import UIKit

final class ConstraintsUtils {
    static func getConstraintsWithFirstItem(ofType: String, constraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        let filteredConstrainst = constraints.filter { $0.firstItem != nil }
            .filter { (constraint) -> Bool in
                NSStringFromClass(type(of: constraint.firstItem!)) == ofType
            }
        return filteredConstrainst
    }

    static func getConstraintsWithSecondItem(ofType: String, constraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        let filteredConstrainst = constraints.filter { $0.secondItem != nil }
            .filter { (constraint) -> Bool in
                NSStringFromClass(type(of: constraint.secondItem!)) == ofType
            }
        return filteredConstrainst
    }

    static func getAnchorName(_ anchor: NSLayoutAnchor<AnyObject>) -> String {
        String(String(describing: anchor).split(separator: ".")[1].split(separator: "\"")[0])
    }
}
