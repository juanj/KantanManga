//
//  AnkiConnectionViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import UIKit

protocol AnkiConnectionViewControllerDelegate: AnyObject {
    func didSelectSave(_ ankiConnectionViewController: AnkiConnectionViewController, host: String, key: String?)
}

class AnkiConnectionViewController: UIViewController {
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
        title = "Anki Connection"

        hostTextField.addTarget(self, action: #selector(checkFields), for: .editingChanged)
        continueButton.isEnabled = false
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

    @IBAction func `continue`(_ sender: Any) {
        guard let host = hostTextField.text, let key = keyTextField.text else { return }
        delegate?.didSelectSave(self, host: host, key: key.isEmpty ? nil : key)
    }
}
