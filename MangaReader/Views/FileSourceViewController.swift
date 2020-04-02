//
//  FileSourceViewController.swift
//  MangaReader
//
//  Created by DevBakura on 1/04/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

protocol FileSourceViewControllerDelegate: AnyObject {
    func openWebServer(fileSourceViewController: FileSourceViewController)
    func openLocalFiles(fileSourceViewController: FileSourceViewController)
}

class FileSourceViewController: UIViewController {
    private weak var delegate: FileSourceViewControllerDelegate?

    init(delegate: FileSourceViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select source"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.preferredContentSize = CGSize(width: 400, height: 88)
    }

    @IBAction func webserver(_ sender: Any) {
        delegate?.openWebServer(fileSourceViewController: self)
    }

    @IBAction func localFiles(_ sender: Any) {
        delegate?.openLocalFiles(fileSourceViewController: self)
    }
}
