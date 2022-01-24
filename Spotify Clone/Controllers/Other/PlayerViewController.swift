//
//  PlayerViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class PlayerViewController: UIViewController {

    // MARK: - Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBlue
        
        return imageView
    }()
    
    private let controlsView: PlayerControlsView = {
        let controlsView = PlayerControlsView()
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        
        return controlsView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(imageView)
        view.addSubview(controlsView)
        
        // Apply delegate pattern of PlayerControlsView
        controlsView.delegate = self
        
        // Configure bar buttons
        configureNavigationBarButtons()
        
        // Configure subviews' constraints
        configureConstraints()
    }
    
    
    // MARK: - Methods
    
    private func configureNavigationBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapAction)
        )
    }
    
    private func configureConstraints() {
        let padding: CGFloat = 15.0
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            controlsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding * 2),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
        ])
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAction() {
        
    }
    
}


// MARK: - Conforms the PlayControlsViewDelegate protocol
extension PlayerViewController: PlayerControlsViewDelegate {
    
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        
    }
    
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView) {
        
    }
    
}
