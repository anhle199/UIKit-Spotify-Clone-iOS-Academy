//
//  FeaturedPlaylistsResponse.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 19/01/2022.
//

import Foundation

struct FeaturedPlaylistsResponse: Codable {
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable {
    let items: [Playlist]
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
