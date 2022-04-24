//
//  AnkiConnectionViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import UIKit

protocol AnkiConnectionViewControllerDelegate: AnyObject {
    func didSelectSave(_ ankiConnectionViewController: AnkiConnectionViewController, host: String, key: String?)
    func cancel(_ ankiConnectionViewController: AnkiConnectionViewController)
}

class AnkiConnectionViewController: UIViewController {
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var continueButton: UIBarButtonItem!

    private weak var delegate: AnkiConnectionViewControllerDelegate?

    init(delegate: AnkiConnectionViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        configureNavBar()
    }

    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        continueButton = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(`continue`))
        continueButton.isEnabled = false
        navigationItem.rightBarButtonItem = continueButton
        title = "Anki connect configuration"
    }

    private func configureTextFields() {
        hostTextField.addTarget(self, action: #selector(checkFields), for: .editingChanged)
    }

    func startLoading() {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }

    func endLoading() {
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }

    @objc func checkFields() {
        if let text = hostTextField.text, !text.isEmpty {
            continueButton.isEnabled = true
        } else {
            continueButton.isEnabled = false
        }
    }

    @objc func `continue`() {
        guard let host = hostTextField.text, let key = keyTextField.text else { return }
        delegate?.didSelectSave(self, host: host, key: key.isEmpty ? nil : key)
    }

    @objc func cancel() {
        delegate?.cancel(self)
    }
}
