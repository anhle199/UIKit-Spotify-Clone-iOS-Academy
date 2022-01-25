//
//  PlaybackPresenter.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 24/01/2022.
//

import UIKit
import AVFoundation

final class PlaybackPresenter {
    
    // Apply Singleton pattern
    static let shared = PlaybackPresenter()
    private init() {}
    
    private var player: AVPlayer?
    private var playerQueue: AVQueuePlayer?
    
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    var currentTrack: AudioTrack? {
        if let track = track {
            return track
            
        }
        
        if !tracks.isEmpty,
           let playerQueue = playerQueue,
           let currentItem = playerQueue.currentItem,
           let index = playerQueue.items().firstIndex(of: currentItem)
        {
            return tracks[tracks.count - playerQueue.items().count + index]
        }
        
        return nil
    }
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        self.player = nil
        self.playerQueue = nil
        
        self.track = track
        self.tracks = []
        
        if let url = URL(string: track.preview_url ?? "") {
            self.player = AVPlayer(url: url)
            self.player?.volume = 0.5
            self.player?.actionAtItemEnd = .pause
        }
        
        let playerVC = PlayerViewController()
        playerVC.title = track.name
        playerVC.navigationItem.largeTitleDisplayMode = .never
        playerVC.dataSource = self
        playerVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: playerVC)
        
        viewController.present(navVC, animated: true) { [weak self] in
            self?.player?.play()
            
            // if player is nil ==> show an alert to notify "Cannot find audio for this song."
            // and only show "Play" icon button
        }
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        self.player = nil
        self.playerQueue = nil
        
        // Update list of tracks
        self.track = nil
        self.tracks = tracks.filter({ URL(string: $0.preview_url ?? "") != nil })
        
        // Create a queue of players
        let playerItems: [AVPlayerItem] = tracks.compactMap { track in
            guard let url = URL(string: track.preview_url ?? "") else {
                return nil
            }
            
            return AVPlayerItem(url: url)
        }
        self.playerQueue = AVQueuePlayer(items: playerItems)
        
        // Create player view controller to show music playing UI
        let playerVC = PlayerViewController()
        playerVC.navigationItem.largeTitleDisplayMode = .never
        playerVC.dataSource = self
        playerVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: playerVC)
        
        // Present music playing UI
        viewController.present(navVC, animated: true) { [weak self] in
            self?.playerQueue?.play()
        }
    }
    
}


// MARK: - Conforms the PlayerViewControllerDelegate
extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
        playerQueue?.volume = value
    }
    
    func didTapPlayPause() {
        var musicPlayer: AVPlayer?
        
        if player != nil {
            musicPlayer = player
        } else if playerQueue != nil {
            musicPlayer = playerQueue
        }
        
        if let musicPlayer = musicPlayer {
            switch musicPlayer.timeControlStatus {
            case .paused:
                musicPlayer.play()
            case .playing:
                musicPlayer.pause()
            default:  // .waitingToPlayAtSpecifiedRate and others
                break
            }
        }
    }
    
    func didTapForward() {
        if let player = player, track != nil {
            // only one track.
            // ends the current player.
            if let duration = player.currentItem?.duration {
                player.seek(to: duration)
                
                // set "Play" icon
            }
        } else if let playerQueue = playerQueue, !tracks.isEmpty {
            playerQueue.advanceToNextItem()
        }
    }
    
    func didTapBackward() {
        if let player = player, track != nil {
            player.seek(to: .zero)
            player.play()
            
        } else if let playerQueue = playerQueue, !tracks.isEmpty {
            
            guard let currentItem = playerQueue.currentItem,
               let index = playerQueue.items().firstIndex(of: currentItem)
            else {
                return
            }
            
            let actualIndex = tracks.count - playerQueue.items().count + index
            
            if actualIndex == 0 {  // current song is the first song
                playerQueue.seek(to: .zero)
            } else {
                playerQueue.pause()
                playerQueue.removeAllItems()
                
                // Recreate a queue of players
                let preparePlayingTracks = Array<AudioTrack>(tracks[actualIndex - 1 ..< tracks.count])
                let playerItems: [AVPlayerItem] = preparePlayingTracks.compactMap { track in
                    guard let url = URL(string: track.preview_url ?? "") else {
                        return nil
                    }
                    
                    return AVPlayerItem(url: url)
                }
                self.playerQueue = AVQueuePlayer(items: playerItems)
                
                self.playerQueue?.play()
            }
        }
    }
    
}



// MARK: - Conforms the PlayerViewControllerDataSource
extension PlaybackPresenter: PlayerViewControllerDataSource {
    
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
}
