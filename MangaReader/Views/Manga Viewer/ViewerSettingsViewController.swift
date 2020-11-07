//
//  ViewerSettingsViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 3/11/20.
//

import UIKit

protocol ViewerSettingsViewControllerDelegate: AnyObject {
    func updatePagesSetting(_ viewerSettingsViewController: ViewerSettingsViewController, setting: ViewerPagesSettings, newValue: SettingValue)
    func updatePageNumbersSetting(_ viewerSettingsViewController: ViewerSettingsViewController, setting: ViewerPageNumberSettings, newValue: SettingValue)
}

class ViewerSettingsViewController: UIViewController {
    @IBOutlet weak var settingsTableView: UITableView!

    private let settings = [
        SettingsSection(title: "Pages", footer: "Use this to view double page spreads", settings: [
            ViewerPagesSettings.offsetByOne(false)
        ]),
        SettingsSection(footer: "By default landscape is double paged and portrait single paged", settings: [
            ViewerPagesSettings.doublePaged(false)
        ]),
        SettingsSection(title: "Page Numbers", settings: [
            ViewerPageNumberSettings.hidePageNumbers(true),
            ViewerPageNumberSettings.offsetPageNumbesr(0)
        ])
    ]

    private weak var delegate: ViewerSettingsViewControllerDelegate?

    init(delegate: ViewerSettingsViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        return settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].settings.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return settings[section].footer
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settings[indexPath.section].settings[indexPath.row]
        switch setting.value {
        case .bool:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleSettingsCell") as! ToggleTableViewCell // swiftlint:disable:this force_cast
            cell.configureFor(setting)
            cell.delegate = self
            return cell
        case .number:
            let cell = tableView.dequeueReusableCell(withIdentifier: "numberSettingsCell") as! NumberTableViewCell // swiftlint:disable:this force_cast
            cell.configureFor(setting)
            cell.delegate = self
            return cell
        }
    }
}

extension ViewerSettingsViewController: SettingValueChangeDelegate {
    func settingValueChanged(_ setting: SettingRepresentable, newValue: SettingValue) {
        if let setting = setting as? ViewerPagesSettings {
            delegate?.updatePagesSetting(self, setting: setting, newValue: newValue)
        } else if let setting = setting as? ViewerPageNumberSettings {
            delegate?.updatePageNumbersSetting(self, setting: setting, newValue: newValue)
        }
    }
}
