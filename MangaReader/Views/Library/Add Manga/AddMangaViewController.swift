//
//  AddMangaViewController.swift
//  MangaReader
//
//  Created by Juan on 30/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

protocol AddMangaViewControllerDelegate: AnyObject {
    func cancel(_ addMangaViewController: AddMangaViewController)
    func save(_ addMangaViewController: AddMangaViewController, name: String?)
    func selectManga(_ addMangaViewController: AddMangaViewController)
    func selectCollection(_ addMangaViewController: AddMangaViewController)
}

class AddMangaViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var selectFileButton: UIButton!
    @IBOutlet weak var selectCollectionButton: UIButton!
    private weak var delegate: AddMangaViewControllerDelegate?
    private var fileName: String?

    init(delegate: AddMangaViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.preferredContentSize = CGSize(width: 400, height: 188)
    }

    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        title = "Add manga"
    }

    @objc func cancel() {
        delegate?.cancel(self)
    }

    @IBAction func selectFile() {
        delegate?.selectManga(self)
    }

    @IBAction func selectCollection() {
        delegate?.selectCollection(self)
    }

    @objc func save() {
        delegate?.save(self, name: nameTextField.text)
    }
}
