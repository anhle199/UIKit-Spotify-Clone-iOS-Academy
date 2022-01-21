//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class PlaylistViewController: UIViewController {

    private let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = playlist.name
        navigationItem.largeTitleDisplayMode = .never
        
        fetchData()
    }

    private func fetchData() {
        APICaller.shared.getPlaylistDetails(for: playlist) { result in
            switch result {
            case .success(let model):
                print(model)
            case .failure(let error):
                print("ERROR - getPlaylistDetails: \(error.localizedDescription)")
            }
        }
    }
    
}
