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
    private var doneButton: UIBarButtonItem!
    private weak var delegate: AddMangaViewControllerDelegate?
    private var fileName: String?

    var hasFile: Bool = false {
        didSet {
            doneButton.isEnabled = isFill()
        }
    }

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
        configureTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.preferredContentSize = CGSize(width: 400, height: 188)
    }

    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
        title = "Add manga"
    }

    private func configureTextField() {
        nameTextField.addTarget(self, action: #selector(refresh), for: .editingChanged)
    }

    private func isFill() -> Bool {
        if hasFile, let text = nameTextField.text, !text.isEmpty {
            return true
        } else {
            return false
        }
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

    @objc func refresh() {
        doneButton.isEnabled = isFill()
    }
}
