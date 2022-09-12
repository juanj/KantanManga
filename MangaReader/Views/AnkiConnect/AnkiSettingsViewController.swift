//
//  AnkiSettingsViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import UIKit

protocol AnkiSettingsViewControllerDelegate: AnyObject {
    func didSelectDeck(_ ankiSettingsViewController: AnkiSettingsViewController)
    func didSelectNoteType(_ ankiSettingsViewController: AnkiSettingsViewController)
    func didSelectWordField(_ ankiSettingsViewController: AnkiSettingsViewController)
    func didSelectReadingField(_ ankiSettingsViewController: AnkiSettingsViewController)
    func didSelectSentenceField(_ ankiSettingsViewController: AnkiSettingsViewController)
    func didSelectDefinitionField(_ ankiSettingsViewController: AnkiSettingsViewController)
    func didSelectImageField(_ ankiSettingsViewController: AnkiSettingsViewController)
    func didSelectSave(_ ankiSettingsViewController: AnkiSettingsViewController)
    func hasEnoughInformation(_ ankiSettingsViewController: AnkiSettingsViewController) -> Bool
    func cancel(_ ankiSettingsViewController: AnkiSettingsViewController)
}

class AnkiSettingsViewController: UIViewController {
    @IBOutlet weak var deckButton: UIButton!
    @IBOutlet weak var noteTypeButton: UIButton!
    @IBOutlet weak var wordFieldButton: UIButton!
    @IBOutlet weak var readingFieldButton: UIButton!
    @IBOutlet weak var sentenceFieldButton: UIButton!
    @IBOutlet weak var definitionFieldButton: UIButton!
    @IBOutlet weak var imageFieldButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var saveButton: UIBarButtonItem!
    
    private weak var delegate: AnkiSettingsViewControllerDelegate?

    init(delegate: AnkiSettingsViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startLoading() {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }

    func endLoading() {
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        saveButton.isEnabled = false
    }

    private func configureNavigationBar() {
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton
        title = "Deck and note"
    }

    private func checkFields() {
        saveButton.isEnabled = delegate?.hasEnoughInformation(self) == true
    }

    func setDeck(_ deck: String) {
        deckButton.setTitle(deck, for: .normal)
        deckButton.setTitleColor(.label, for: .normal)
        checkFields()
    }

    func setNoteType(_ noteType: String) {
        noteTypeButton.setTitle(noteType, for: .normal)
        noteTypeButton.setTitleColor(.label, for: .normal)
        checkFields()
    }

    func setWordField(_ wordField: String) {
        wordFieldButton.setTitle(wordField, for: .normal)
        wordFieldButton.setTitleColor(.label, for: .normal)
        checkFields()
    }

    func setReadingField(_ readingField: String) {
        readingFieldButton.setTitle(readingField, for: .normal)
        readingFieldButton.setTitleColor(.label, for: .normal)
        checkFields()
    }

    func setSentenceField(_ sentenceField: String) {
        sentenceFieldButton.setTitle(sentenceField, for: .normal)
        sentenceFieldButton.setTitleColor(.label, for: .normal)
        checkFields()
    }

    func setDefinitionField(_ definitionField: String) {
        definitionFieldButton.setTitle(definitionField, for: .normal)
        definitionFieldButton.setTitleColor(.label, for: .normal)
        checkFields()
    }

    func setImageField(_ imageField: String) {
        imageFieldButton.setTitle(imageField, for: .normal)
        imageFieldButton.setTitleColor(.label, for: .normal)
        checkFields()
    }

    @IBAction func selectField(_ button: UIButton) {
        switch button {
        case deckButton:
            delegate?.didSelectDeck(self)
        case noteTypeButton:
            delegate?.didSelectNoteType(self)
        case wordFieldButton:
            delegate?.didSelectWordField(self)
        case readingFieldButton:
            delegate?.didSelectReadingField(self)
        case sentenceFieldButton:
            delegate?.didSelectSentenceField(self)
        case definitionFieldButton:
            delegate?.didSelectDefinitionField(self)
        case imageFieldButton:
            delegate?.didSelectImageField(self)
        default:
            break
        }
    }

    @objc func save() {
        delegate?.didSelectSave(self)
    }

    @objc func cancel() {
        delegate?.cancel(self)
    }
}

extension AnkiSettingsViewController: UITextFieldDelegate {

}
