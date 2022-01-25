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
    
    private var playerVC: PlayerViewController?
    
    private var isTappedForwardButton = false
    private var setFinishASongIfNeeded = false
    
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
        removeAllObserves()
        
        self.player = nil
        self.playerQueue = nil
        
        self.track = track
        self.tracks = []
        
        if let url = URL(string: track.preview_url ?? "") {
            self.player = AVPlayer(url: url)
            self.player?.volume = 0.5
            self.player?.actionAtItemEnd = .pause
            self.setFinishASongIfNeeded = true
            
            // Observing a player item and it will be triggered play/pause button when playing to end time
            addAllObserves()
        }
        
        let playerVC = PlayerViewController()
        playerVC.title = track.name
        playerVC.navigationItem.largeTitleDisplayMode = .never
        playerVC.dataSource = self
        playerVC.delegate = self
        self.playerVC = playerVC
        
        let navVC = UINavigationController(rootViewController: playerVC)
        
        viewController.present(navVC, animated: true) { [weak self] in
            self?.player?.play()
            
            // if player is nil ==> show an alert to notify "Cannot find audio for this song."
            // and only show "Play" icon button
        }
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        removeAllObserves()
        
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
        self.setFinishASongIfNeeded = true
        
        // Observing all player items and each item will be triggered play/pause button when playing to end time
        addAllObserves()
        
        // Create player view controller to show music playing UI
        let playerVC = PlayerViewController()
        playerVC.navigationItem.largeTitleDisplayMode = .never
        playerVC.dataSource = self
        playerVC.delegate = self
        self.playerVC = playerVC
        
        let navVC = UINavigationController(rootViewController: playerVC)
        
        // Present music playing UI
        viewController.present(navVC, animated: true) { [weak self] in
            self?.playerQueue?.play()
        }
    }
 
}


// MARK: - Applying Observable Pattern to AVPlayerItem
extension PlaybackPresenter {
    
    @objc private func playerDidFinishPlaying(_ sender: Notification) {
        print("playerDidFinishPlaying - 127")
        if isTappedForwardButton {
            if player != nil {
                playerVC?.updateStatusOfPlayPauseButton(withIsPlaying: false)
                print("playerDidFinishPlaying - 131")
            } else if let playerQueue = playerQueue, playerQueue.items().count == 1 {
                playerVC?.updateStatusOfPlayPauseButton(withIsPlaying: false)
                playerQueue.actionAtItemEnd = .pause
                print("playerDidFinishPlaying - 135")
            }
            
            self.isTappedForwardButton = false
            
        } else if setFinishASongIfNeeded {  // isTappedForwardButton is false
            if let player = player, track != nil {
                print("playerDidFinishPlaying - 142")
                // only one track.
                // ends the current player.
                if let duration = player.currentItem?.duration {
//                    self.setFinishASongIfNeeded = false
                    player.seek(to: duration)
                    playerVC?.updateStatusOfPlayPauseButton(withIsPlaying: false)
                    print("playerDidFinishPlaying - 149")
                }
                
            } else if let playerQueue = playerQueue, !tracks.isEmpty {
                print("playerDidFinishPlaying - 153")
                if playerQueue.items().count == 1,
                   let duration = playerQueue.currentItem?.duration {
                    print("playerDidFinishPlaying - 156")
                    self.setFinishASongIfNeeded = false
                    playerQueue.actionAtItemEnd = .pause
                    playerQueue.seek(to: duration)
                    playerVC?.updateStatusOfPlayPauseButton(withIsPlaying: false)
                } else if playerQueue.items().count > 1 {
                    print("playerDidFinishPlaying - 162")
                    NotificationCenter.default.removeObserver(
                        self,
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: playerQueue.currentItem
                    )
                    
                    playerVC?.refreshUI()
                }
            }
        }
    }
    
    private func addAllObserves() {
        if let player = player {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        } else if let playerQueue = playerQueue {
            playerQueue.items().forEach { [weak self] item in
                if let safeSelf = self {
                    NotificationCenter.default.addObserver(
                        safeSelf,
                        selector: #selector(playerDidFinishPlaying),
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: item
                    )
                }
            }
        }
    }
    
    private func removeAllObserves() {
        if let player = player {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        } else if let playerQueue = playerQueue {
            playerQueue.items().forEach { [weak self] item in
                if let safeSelf = self {
                    NotificationCenter.default.removeObserver(
                        safeSelf,
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: item
                    )
                }
            }
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
        if let player = player {
            if player.timeControlStatus == .paused {
                if let duration = player.currentItem?.duration,
                   duration == player.currentTime() {
                    
                    player.seek(to: .zero)
                }
                
                player.play()
            } else if player.timeControlStatus == .playing {
                player.pause()
            }
            
        } else if let playerQueue = playerQueue {
           if playerQueue.timeControlStatus == .paused {
                if let duration = playerQueue.currentItem?.duration,
                   duration == playerQueue.currentTime(),
                   playerQueue.items().count == 1 {
                    
                    playerQueue.seek(to: .zero)
                    playerQueue.actionAtItemEnd = .advance
                }
                
                playerQueue.play()
            } else if playerQueue.timeControlStatus == .playing {
                playerQueue.pause()
            }
        }
    }
    
    func didTapForward() {
        self.isTappedForwardButton = true
        
        if let player = player, track != nil {
            // only one track.
            // ends the current player.
            if let duration = player.currentItem?.duration {
                player.seek(to: duration)
            }

        } else if let playerQueue = playerQueue, !tracks.isEmpty {
            
            if playerQueue.items().count == 1,
               let duration = playerQueue.currentItem?.duration {
                
                playerQueue.actionAtItemEnd = .pause
                playerQueue.seek(to: duration)
            } else if playerQueue.items().count > 1 {
                NotificationCenter.default.removeObserver(
                    self,
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: playerQueue.currentItem
                )
                
                playerQueue.advanceToNextItem()
                playerVC?.refreshUI()
            }
        }
    }
    
    func didTapBackward() {
        if let player = player, track != nil {
            player.seek(to: .zero)

        } else if let playerQueue = playerQueue, !tracks.isEmpty {
            
            guard let currentItem = playerQueue.currentItem,
                  let index = playerQueue.items().firstIndex(of: currentItem)
            else {
                return
            }
            
            let actualIndex = tracks.count - playerQueue.items().count + index
            
            if actualIndex == 0 {  // the first song in the original list of tracks
                playerQueue.seek(to: .zero)
            } else {
                removeAllObserves()
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
                addAllObserves()
                
                self.playerQueue?.play()
                playerVC?.refreshUI()
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
