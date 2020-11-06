//
//  ToggleTableViewCell.swift
//  Kantan-Manga
//
//  Created by Juan on 3/11/20.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var switchControl: UISwitch!

    weak var delegate: SettingValueChangeDelegate?
    private var setting: SettingRepresentable?

    override func awakeFromNib() {
        super.awakeFromNib()

        switchControl.addTarget(self, action: #selector(updateValue), for: .valueChanged)
    }

    func configureFor(_ setting: SettingRepresentable) {
        guard case .bool(let value) = setting.value else {
            fatalError("ToggleTableViewCell can only be configured with a setting of type .bool")
        }

        switchControl.isOn = value
        label.text = setting.title
        self.setting = setting
    }

    @objc private func updateValue() {
        guard let setting = setting else { return }
        delegate?.settingValueChanged(setting, newValue: .bool(value: switchControl.isOn))
    }
}
