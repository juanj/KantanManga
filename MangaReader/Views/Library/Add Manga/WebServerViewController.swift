//
//  WebServerViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol WebServerViewControllerDelegate: AnyObject {
    func didSelectBack(_ webServerViewController: WebServerViewController)
}

class WebServerViewController: UIViewController {
    @IBOutlet weak var openLabel: UILabel!

    weak var delegate: WebServerViewControllerDelegate?
    var serverUrl = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        openLabel.text = "Open your browser\nat\n \(serverUrl)"
        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.preferredContentSize = CGSize(width: 400, height: 175)
    }

    func configureNavigationBar() {
        title = "Web Server"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
    }

    @objc func back() {
        delegate?.didSelectBack(self)
    }
}
