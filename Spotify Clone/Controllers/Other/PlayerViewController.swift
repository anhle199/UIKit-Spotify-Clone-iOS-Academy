//
//  PlayerViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    
    func didSlideSlider(_ value: Float)
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    
}

protocol PlayerViewControllerDataSource: AnyObject {
    
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
    
}

class PlayerViewController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: PlayerViewControllerDelegate?
    weak var dataSource: PlayerViewControllerDataSource?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = .systemBlue
        
        
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
        
        // Configure subviews' data
        configureData()
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
        let padding: CGFloat = 10.0
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            controlsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding * 1.2),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding * 3),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
        ])
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
    }
    
    private func configureData() {
        imageView.sd_setImage(
            with: dataSource?.imageURL,
            placeholderImage: UIImage(systemName: "photo"),
            completed: nil
        )
        controlsView.configure(with: PlayerControlsViewViewModel(
            songName: dataSource?.songName,
            subtitle: dataSource?.subtitle
        ))
    }

    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAction() {
        
    }
    
    public func refreshUI() {
        configureData()
    }
    
    public func updateStatusOfPlayPauseButton(withIsPlaying isPlaying: Bool) {
        controlsView.updateStatusOfPlayPauseButton(withIsPlaying: isPlaying)
    }
    
}


// MARK: - Conforms the PlayControlsViewDelegate protocol
extension PlayerViewController: PlayerControlsViewDelegate {
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward() 
    }
    
}
