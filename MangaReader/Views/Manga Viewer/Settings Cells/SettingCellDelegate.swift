//
//  SettingCellDelegate.swift
//  Kantan-Manga
//
//  Created by Juan on 4/11/20.
//

import Foundation

protocol SettingCellDelegate {
    func valueDidChange(setting: Setting, newValue: SettingType)
}
