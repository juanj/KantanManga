//
//  Setting.swift
//  Kantan-Manga
//
//  Created by Juan on 4/11/20.
//

import Foundation

enum SettingType {
    case toggle(value: Bool)
    case number(value: Int)
}

struct Setting {
    let name: String
    let type: SettingType
}
