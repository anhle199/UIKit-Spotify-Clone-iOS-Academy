//
//  AlbumViewController.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 21/01/2022.
//

import UIKit

class AlbumViewController: UIViewController {

    private let album: Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = album.name
        navigationItem.largeTitleDisplayMode = .never
        
        fetchData()
    }
    
    private func fetchData() {
        APICaller.shared.getAlbumDetails(for: album) { result in
            switch result {
            case .success(let model):
                print(model)
            case .failure(let error):
                print("ERROR - getAlbumDetails: \(error.localizedDescription)")
            }
        }
    }
    
}
