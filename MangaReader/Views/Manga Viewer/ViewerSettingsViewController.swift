//
//  ViewerSettingsViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 3/11/20.
//

import UIKit

class ViewerSettingsViewController: UIViewController {
    @IBOutlet weak var settingsTableView: UITableView!

    let settingsSections = [
        SettingsSection(title: "Page Numbers", settings: [
            Setting(name: "Show page numbers", type: .toggle(value: true)),
            Setting(name: "Offset page numbers by", type: .number(value: 0))
        ]),
        SettingsSection(title: "Pages", settings: [
            Setting(name: "Double paged", type: .toggle(value: true)),
            Setting(name: "Offset pages by 1 (use this to view double page spreads)", type: .toggle(value: false))
        ])
    ]

    override func viewDidLoad() {
        title = "Viewer Settings"
        settingsTableView.register(UINib(nibName: "ToggleTableViewCell", bundle: nil), forCellReuseIdentifier: "toggleSettingsCell")
        settingsTableView.register(UINib(nibName: "NumberTableViewCell", bundle: nil), forCellReuseIdentifier: "numberSettingsCell")
        settingsTableView.dataSource = self
        settingsTableView.allowsSelection = false
    }
}

extension ViewerSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsSections[section].settings.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsSections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settingsSections[indexPath.section].settings[indexPath.row]
        switch setting.type {
        case .toggle(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleSettingsCell") as! ToggleTableViewCell // swiftlint:disable:this force_cast
            cell.label.text = setting.name
            cell.switchControl.isOn = value
            return cell
        case .number(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: "numberSettingsCell") as! NumberTableViewCell // swiftlint:disable:this force_cast
            cell.label.text = setting.name
            cell.textField.text = String(value)
            return cell
        }
    }
}
