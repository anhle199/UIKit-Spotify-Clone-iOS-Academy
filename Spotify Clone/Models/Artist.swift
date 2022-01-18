//
//  Artist.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import Foundation

struct Artist: Codable {
    let external_urls: [String: String]
    let id: String
    let name: String
    let type: String
}
