//
//  CreateSentenceViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import UIKit

protocol CreateSentenceViewControllerDelegate: AnyObject {
    func cancel(_ createSentenceViewController: CreateSentenceViewController)
    func save(_ createSentenceViewController: CreateSentenceViewController, word: String, reading: String, sentence: String, definition: String)
    func delete(_ createSentenceViewController: CreateSentenceViewController)
    func editImage(_ createSentenceViewController: CreateSentenceViewController)
}

extension CreateSentenceViewControllerDelegate {
    // Optional method
    func delete(_ createSentenceViewController: CreateSentenceViewController) {}
}

class CreateSentenceViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var readingTextField: UITextField!
    @IBOutlet weak var sentenceTextField: UITextField!
    @IBOutlet weak var definitionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!

    private let image: UIImage?
    private let word: String
    private let reading: String
    private let sentence: String
    private let definition: String
    private let isExistingSentence: Bool
    private weak var delegate: CreateSentenceViewControllerDelegate?
    init(
        image: UIImage?,
        word: String,
        reading: String,
        sentence: String,
        definition: String,
        isExistingSentence: Bool,
        delegate: CreateSentenceViewControllerDelegate
    ) {
        self.image = image
        self.word = word
        self.reading = reading
        self.sentence = sentence
        self.definition = definition
        self.isExistingSentence = isExistingSentence
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

    func setImage(_ image: UIImage) {
        imageView.image = image
    }

    private func loadData() {
        imageView.image = image
        wordTextField.text = word
        readingTextField.text = reading
        sentenceTextField.text = sentence
        definitionTextView.text = definition
    }

    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))]

        if isExistingSentence {
            title = "Edit sentence"
            navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSentence)))
        } else {
            title = "Save sentence"
        }
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
        delegate?.save(
            self,
            word: wordTextField.text ?? "",
            reading: readingTextField.text ?? "",
            sentence: sentenceTextField.text ?? "",
            definition: definitionTextView.text ?? ""
        )
    }

    @objc func deleteSentence() {
        delegate?.delete(self)
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
