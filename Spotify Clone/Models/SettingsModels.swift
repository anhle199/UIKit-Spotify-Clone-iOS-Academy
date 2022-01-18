//
//  SettingsModels.swift
//  Spotify
//
//  Created by Le Hoang Anh on 18/01/2022.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
