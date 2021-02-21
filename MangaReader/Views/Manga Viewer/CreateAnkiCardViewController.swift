//
//  CreateAnkiCardViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import UIKit

protocol CreateAnkiCardViewControllerDelegate: AnyObject {
    func cancel(_ createAnkiCardViewController: CreateAnkiCardViewController)
    func save(_ createAnkiCardViewController: CreateAnkiCardViewController)
    func editImage(_ createAnkiCardViewController: CreateAnkiCardViewController)
}

class CreateAnkiCardViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sentenceTextField: UITextField!
    @IBOutlet weak var definitionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!

    private let image: UIImage
    private let sentence: String
    private let term: Term
    private weak var delegate: CreateAnkiCardViewControllerDelegate?
    init(image: UIImage, sentence: String, term: Term, delegate: CreateAnkiCardViewControllerDelegate) {
        self.image = image
        self.sentence = sentence
        self.term = term
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        configureNavigationBar()
        configureScrollView()
        configureGestures()
    }

    private func loadData() {
        imageView.image = image
        sentenceTextField.text = sentence

        var definition = ""
        definition += "\(term.reading)"
        if term.expression != term.reading {
            definition += " 【\(term.expression)】"
        }

        for glossary in term.glossary {
            switch glossary {
            case .text(let text):
                definition += "\n• \(text)"
            default: break
            }
        }
        definitionTextView.text = definition
    }

    private func configureNavigationBar() {
        title = "Create Anki Card"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    private func configureScrollView() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editImage))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }

    @objc func cancel() {
        delegate?.cancel(self)
    }

    @objc func save() {
        delegate?.save(self)
    }

    @objc func editImage() {
        delegate?.editImage(self)
    }

    @objc func handleKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        if notification.name == UIResponder.keyboardWillShowNotification {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}
