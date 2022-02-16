//
//  LibraryToggleView.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 12/02/2022.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {

    enum State {
        case playlist
        case album
    }
    
    weak var delegate: LibraryToggleViewDelegate?
    
    private let playlistsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Playlists", for: .normal)
        button.setTitleColor(.label, for: .normal)
        
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Albums", for: .normal)
        button.setTitleColor(.label, for: .normal)
        
        return button
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        
        return view
    }()
    
    // These variables will be used to change state and position of indicator view
    // when a button is pressed
    var buttonState = State.playlist
    private var indicatorViewLeadingConstraintWhenPressingPlaylists: NSLayoutConstraint?
    private var indicatorViewLeadingConstraintWhenPressingAlbums: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        setupSubviews()
        setupConstraints()
        
        playlistsButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    private func setupSubviews() {
        addSubview(playlistsButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
    }
    
    private func setupConstraints() {
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 50
        let indicatorHeight: CGFloat = 3
        
        indicatorViewLeadingConstraintWhenPressingPlaylists = indicatorView.leadingAnchor.constraint(
            equalTo: leadingAnchor
        )
        indicatorViewLeadingConstraintWhenPressingAlbums = indicatorView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: buttonWidth
        )
        
        NSLayoutConstraint.activate([
            playlistsButton.topAnchor.constraint(equalTo: topAnchor),
            playlistsButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            playlistsButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            playlistsButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            albumsButton.topAnchor.constraint(equalTo: topAnchor),
            albumsButton.leadingAnchor.constraint(equalTo: playlistsButton.trailingAnchor),
            albumsButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            albumsButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            indicatorView.topAnchor.constraint(equalTo: topAnchor, constant: buttonHeight),
            indicatorView.widthAnchor.constraint(equalToConstant: buttonWidth),
            indicatorView.heightAnchor.constraint(equalToConstant: indicatorHeight),
        ])
        
        updateIndicatorViewConstraint()
    }
    
    private func updateIndicatorViewConstraint() {
        switch buttonState {
        case .playlist:
            indicatorViewLeadingConstraintWhenPressingAlbums?.isActive = false
            indicatorViewLeadingConstraintWhenPressingPlaylists?.isActive = true
        case .album:
            indicatorViewLeadingConstraintWhenPressingPlaylists?.isActive = false
            indicatorViewLeadingConstraintWhenPressingAlbums?.isActive = true
        }
    }
    
    func updateIndicatorView(for state: State) {
        buttonState = state
        
        UIView.animate(withDuration: 0.2) {
            self.updateIndicatorViewConstraint()
            self.indicatorView.layoutIfNeeded()
        }
    }
    
    @objc private func didTapPlaylists(_ button: UIButton) {
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }
    
    @objc private func didTapAlbums(_ button: UIButton) {
        delegate?.libraryToggleViewDidTapAlbums(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
