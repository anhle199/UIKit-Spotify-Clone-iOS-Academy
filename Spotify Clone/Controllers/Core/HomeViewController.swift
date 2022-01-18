//
//  HomeViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        
        fetchData()
    }
    
    private func fetchData() {
        APICaller.shared.getAvailableGenreSeeds { result in
            switch (result) {
            case .success(let model):
                let genres = model.genres
                var seedGenres = Set<String>()
                
                while seedGenres.count < 5 {
                    if let random = genres.randomElement() {
                        seedGenres.insert(random)
                    }
                }
                
                APICaller.shared.getRecommendations(genres: seedGenres) { _ in
                    
                }
                
            case .failure(let error):
                break
            }
        }
    }

    @objc func didTapSettings(_ sender: UIBarButtonItem) {
        let profileVC = SettingsViewController()
        profileVC.title = "Settings"
        profileVC.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
}
