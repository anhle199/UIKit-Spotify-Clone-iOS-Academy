//
//  AllCategoriesResponse.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 22/01/2022.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}
