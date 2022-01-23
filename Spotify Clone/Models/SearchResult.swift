//
//  SearchResult.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 23/01/2022.
//

import Foundation

enum SearchResult {
    case album(model: Album)
    case artist(model: Artist)
    case playlist(model: Playlist)
    case track(model: AudioTrack)
}
