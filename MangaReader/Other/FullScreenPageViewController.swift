//
//  FullScreenPageViewController.swift
//  MangaReader
//
//  Created by admin on 2/21/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

class FullScreenPageViewController: UIPageViewController {
    public var fullScreen = false

    override var prefersStatusBarHidden: Bool {
        return fullScreen
    }

    public func troggleFullscreen() {
        fullScreen = !fullScreen
        setNeedsStatusBarAppearanceUpdate()
    }
}
