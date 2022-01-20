//
//  NewReleasesResponse.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 19/01/2022.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let artists: [Artist]
    let available_markets: [String]
    let id: String
    let images: [APIImage]
    let name: String
    let release_date: String
    let release_date_precision: String
    let total_tracks: Int
}
