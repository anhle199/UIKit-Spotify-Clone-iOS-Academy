//
//  LibraryPlaylistsResponse.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 13/02/2022.
//

import Foundation

struct LibraryPlaylistsResponse: Codable {
    let items: [Playlist]
}

struct LibraryAlbumsResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}
