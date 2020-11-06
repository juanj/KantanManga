//
//  SettingValueChangeDelegate.swift
//  Kantan-Manga
//
//  Created by Juan on 6/11/20.
//

import Foundation

protocol SettingValueChangeDelegate: AnyObject {
    func settingValueChanged(_ setting: SettingRepresentable, newValue: SettingValue)
}
