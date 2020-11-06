//
//  NumberTableViewCell.swift
//  Kantan-Manga
//
//  Created by Juan on 4/11/20.
//

import UIKit

class NumberTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var valueLabel: UILabel!

    weak var delegate: SettingValueChangeDelegate?
    private var setting: SettingRepresentable?

    override func awakeFromNib() {
        super.awakeFromNib()

        stepper.addTarget(self, action: #selector(updateValue), for: .valueChanged)
    }

    func configureFor(_ setting: SettingRepresentable) {
        guard case .number(let value) = setting.value else {
            fatalError("NumberTableViewCell can only be configured with a setting of type .number")
        }

        valueLabel.text = String(value)
        label.text = setting.title
        self.setting = setting
    }

    @objc private func updateValue() {
        guard let setting = setting else { return }
        valueLabel.text = String(Int(stepper.value))
        delegate?.settingValueChanged(setting, newValue: .number(value: Int(stepper.value)))
    }
}
