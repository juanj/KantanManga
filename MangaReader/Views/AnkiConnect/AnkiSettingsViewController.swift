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
}

class AnkiSettingsViewController: UIViewController {
    @IBOutlet weak var deckTextField: UITextField!
    @IBOutlet weak var noteTypeTextField: UITextField!
    @IBOutlet weak var wordFieldTextField: UITextField!
    @IBOutlet weak var readingFieldTextField: UITextField!
    @IBOutlet weak var sentenceFieldTextField: UITextField!
    @IBOutlet weak var definitionFieldTextField: UITextField!
    @IBOutlet weak var imageFieldTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        title = "Settings"

        deckTextField.delegate = self
        noteTypeTextField.delegate = self
        wordFieldTextField.delegate = self
        readingFieldTextField.delegate = self
        sentenceFieldTextField.delegate = self
        definitionFieldTextField.delegate = self
        imageFieldTextField.delegate = self

        saveButton.isEnabled = false
    }

    func setDeck(_ deck: String) {
        deckTextField.text = deck
        checkFields()
    }

    func setNoteType(_ noteType: String) {
        noteTypeTextField.text = noteType
        checkFields()
    }

    func setWordField(_ wordField: String) {
        wordFieldTextField.text = wordField
        checkFields()
    }

    func setReadingField(_ readingField: String) {
        readingFieldTextField.text = readingField
        checkFields()
    }

    func setSentenceField(_ sentenceField: String) {
        sentenceFieldTextField.text = sentenceField
        checkFields()
    }

    func setDefinitionField(_ definitionField: String) {
        definitionFieldTextField.text = definitionField
        checkFields()
    }

    func setImageField(_ imageField: String) {
        imageFieldTextField.text = imageField
        checkFields()
    }

    private func checkFields() {
        guard let deck = deckTextField.text, !deck.isEmpty,
              let noteType = noteTypeTextField.text, !noteType.isEmpty
        else {
            saveButton.isEnabled = false
            return
        }

        if wordFieldTextField.text?.isEmpty == false ||
            readingFieldTextField.text?.isEmpty == false ||
            sentenceFieldTextField.text?.isEmpty == false ||
            definitionFieldTextField.text?.isEmpty == false ||
            imageFieldTextField.text?.isEmpty == false
        {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    @IBAction func save(_ sender: Any) {
        delegate?.didSelectSave(self)
    }
}

extension AnkiSettingsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case deckTextField:
            delegate?.didSelectDeck(self)
        case noteTypeTextField:
            delegate?.didSelectNoteType(self)
        case wordFieldTextField:
            delegate?.didSelectWordField(self)
        case readingFieldTextField:
            delegate?.didSelectReadingField(self)
        case sentenceFieldTextField:
            delegate?.didSelectSentenceField(self)
        case definitionFieldTextField:
            delegate?.didSelectDefinitionField(self)
        case imageFieldTextField:
            delegate?.didSelectImageField(self)
        default:
            break
        }
        return false
    }
}
