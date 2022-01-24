//
//  PlaybackPresenter.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 24/01/2022.
//

import UIKit

final class PlaybackPresenter {
    
    static func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        let playerVC = PlayerViewController()
        playerVC.title = track.name
        playerVC.navigationItem.largeTitleDisplayMode = .never
        
        let navVC = UINavigationController(rootViewController: playerVC)
        
        viewController.present(navVC, animated: true, completion: nil)
    }
    
    static func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        let playerVC = PlayerViewController()
        let navVC = UINavigationController(rootViewController: playerVC)
        viewController.present(navVC, animated: true, completion: nil)
    }
    
}
