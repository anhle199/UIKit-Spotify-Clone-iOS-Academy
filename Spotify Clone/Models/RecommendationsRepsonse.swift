//
//  RecommendationsRepsonse.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 19/01/2022.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
