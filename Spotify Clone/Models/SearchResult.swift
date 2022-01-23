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
    
    func isSame(with searchResultType: String) -> Bool {
        if searchResultType == "All" {
            return true
        }
        
        switch self {
            case .album:
                return searchResultType == "Albums"
            case .artist:
                return searchResultType == "Artists"
            case .playlist:
                return searchResultType == "Playlists"
            case .track:
                return searchResultType == "Songs"
        }
    }
}
