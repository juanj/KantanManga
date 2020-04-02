//
//  NewCollectionTableViewCell.swift
//  MangaReader
//
//  Created by Juan on 2/04/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

protocol NewCollectionTableViewCellDelegate: AnyObject {
    func didEnterName(name: String)
}

class NewCollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var nameTextField: UITextField!
    weak var delegate: NewCollectionTableViewCellDelegate?

    override func awakeFromNib() {
        nameTextField.delegate = self
    }
}

extension NewCollectionTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let name = textField.text, !name.isEmpty else { return false}
        delegate?.didEnterName(name: name)
        return true
    }
}
