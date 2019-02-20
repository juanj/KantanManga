//
//  WebServerViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol WebServerViewControllerDelegate {
    func didSelectBack(_ webServerViewController: WebServerViewController)
}

class WebServerViewController: UIViewController {
    @IBOutlet weak var openLabel: UILabel!
    
    var delegate: WebServerViewControllerDelegate?
    var serverUrl = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.openLabel.text = "Open your browser at \(self.serverUrl)"
        self.configureNavigationBar()
    }
    
    func configureNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
    }
    
    @objc func back() {
        self.delegate?.didSelectBack(self)
    }
}
