//
//  LibraryViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class LibraryViewController: UIViewController {

    private let playlistsVC = LibraryPlaylistsViewController()
    private let albumsVC = LibraryAlbumsViewController()
    
    private let pageView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    private let toggleView: LibraryToggleView = {
        let toggleView = LibraryToggleView()
        toggleView.translatesAutoresizingMaskIntoConstraints = false
        
        return toggleView
    }()
    
    private let playlistRightBarButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: nil,
        action: nil
    )
    
    private var playlistsPageOffset: CGPoint {
        return .zero
    }
    
    private var albumsPageOffset: CGPoint {
        return .init(x: view.frame.width, y: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        pageView.backgroundColor = .red
        
        pageView.delegate = self
        toggleView.delegate = self
        
        addChildren()
        
        setupSubviews()
        setupConstraints()
        
        setUpPlaylistRightBarButton()
    }
    
    private func addChildren() {
        addChild(playlistsVC)
        pageView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(x: 0, y: 0, width: pageView.frame.width, height: pageView.frame.height)
        playlistsVC.didMove(toParent: self)
        
        addChild(albumsVC)
        pageView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.frame.width, y: 0, width: pageView.frame.width, height: pageView.frame.height)
        albumsVC.didMove(toParent: self)
    }
    
    private func setupSubviews() {
        view.addSubview(pageView)
        view.addSubview(toggleView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            
            toggleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toggleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toggleView.widthAnchor.constraint(equalToConstant: 200),
            toggleView.heightAnchor.constraint(equalToConstant: 55),
        ])
        
        pageView.contentSize = CGSize(width: view.frame.width * 2, height: pageView.frame.height)
    }
    
    private func setUpPlaylistRightBarButton() {
        playlistRightBarButton.target = self
        playlistRightBarButton.action = #selector(didTapAdd)
    }
    
    @objc private func didTapAdd() {
        playlistsVC.showCreatePlaylistAlert()
    }
    
    private func updateBarButtons() {
        if toggleView.buttonState == .playlist {
            navigationItem.rightBarButtonItem = playlistRightBarButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension LibraryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= view.frame.width - 100 {
            toggleView.updateIndicatorView(for: .album)
            updateBarButtons()
        } else {
            toggleView.updateIndicatorView(for: .playlist)
            updateBarButtons()
        }
    }
    
}


// MARK: - LibraryToggleViewDelegate
extension LibraryViewController: LibraryToggleViewDelegate {
    
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        // position of indicator view will be updated by scrollViewDidScroll() method automatically
        pageView.setContentOffset(playlistsPageOffset, animated: true)
    }
    
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        // position of indicator view will be updated by scrollViewDidScroll() method automatically
        pageView.setContentOffset(albumsPageOffset, animated: true)
    }
    
}
