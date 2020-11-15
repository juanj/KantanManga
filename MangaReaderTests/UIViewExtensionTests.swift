//
//  UIViewExtensionTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 15/11/20.
//

import XCTest
import UIKit
@testable import Kantan_Manga

class UIViewExtensionTests: XCTestCase {
    func testAddCenterConstraintsTo_subviewInsideSuperView_adds2ConstraintsToSuperview() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let otherView = UIView()
        otherView.addSubview(view)

        view.addCenterConstraintsTo(otherView)

        XCTAssertEqual(otherView.constraints.count, 2)
    }

    func testAddCenterConstraintsTo_customOffset_addsConstraintsWithConstant() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let otherView = UIView()
        otherView.addSubview(view)

        view.addCenterConstraintsTo(otherView, offset: CGPoint(x: 10, y: 10))

        XCTAssertEqual(otherView.constraints.first?.constant, 10)
    }

    func testAddConstraintsTo_allSidesNoSpacing_adds4ConstraintsToSuperView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let otherView = UIView()
        otherView.addSubview(view)

        view.addConstraintsTo(otherView)

        XCTAssertEqual(otherView.constraints.count, 4)
    }

    func testAddConstraintsTo_horizontalOnly_adds2ConstraintsToSuperView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let otherView = UIView()
        otherView.addSubview(view)

        view.addConstraintsTo(otherView, sides: .horizontal)

        XCTAssertEqual(otherView.constraints.count, 2)
    }

    func testAddConstraintsTo_verticalOnly_adds2ConstraintsToSuperView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let otherView = UIView()
        otherView.addSubview(view)

        view.addConstraintsTo(otherView, sides: .vertical)

        XCTAssertEqual(otherView.constraints.count, 2)
    }
}
