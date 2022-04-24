//
//  AnkiConfigManager.swift
//  Kantan-Manga
//
//  Created by Juan on 21/05/21.
//

import Foundation

class AnkiConfigManager {
    private let userDefaults: UserDefaults
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func savedConfig() -> AnkiConfig? {
        guard let data = userDefaults.data(forKey: Constants.UserDefaultsKeys.ankiConfig) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(AnkiConfig.self, from: data)
    }

    func saveConfig(_ config: AnkiConfig) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(config) else { return }
        userDefaults.setValue(data, forKey: Constants.UserDefaultsKeys.ankiConfig)
    }
}
