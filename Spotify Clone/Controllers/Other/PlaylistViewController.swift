//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class PlaylistViewController: UIViewController {

    // MARK: - Properties
    
    private let playlist: Playlist
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout {
                _, _ -> NSCollectionLayoutSection? in
                
                return PlaylistViewController.makeSectionLayout()
            }
        )
        
        return collectionView
    }()
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
    // MARK: - Initializers
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configures this view
        view.backgroundColor = .systemBackground
        title = playlist.name
        navigationItem.largeTitleDisplayMode = .never
        
        // configures collection view
        view.addSubview(collectionView)
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        collectionView.register(
            RecommendedTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // fetches data
        fetchData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    // MARK: - Methods

    @objc private func didTapShare() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(activityVC, animated: true, completion: nil)
    }
    
    private func fetchData() {
        APICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({ $0.track })
                    self?.viewModels = model.tracks.items.compactMap { playlistItem in
                        return RecommendedTrackCellViewModel(
                            name: playlistItem.track.name,
                            artworkURL: URL(string: playlistItem.track.album?.images.first?.url ?? ""),
                            artistName: playlistItem.track.artists.first?.name ?? "-"
                        )
                    }
                    
                    self?.collectionView.reloadData()
                    
                case .failure(let error):
                    print("ERROR - getPlaylistDetails: \(error.localizedDescription)")
                }
            }
        }
    }
    
}


// MARK: - Section Layout
extension PlaylistViewController {
    
    private static func makeSectionLayout() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3, leading: 3, bottom: 3, trailing: 3
        )
    
        // Group
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(80)
            ),
            subitem: item,
            count: 1
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        
        // Header
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.0)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        return section
    }
    
}


// MARK: - Conforms UICollectionViewDelegate
extension PlaylistViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        PlaybackPresenter.shared.startPlayback(from: self, track: tracks[indexPath.row])
    }
    
}


// MARK: - Conforms UICollectionViewDataSource
extension PlaylistViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? PlaylistHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        
        let headerViewModel = PlaylistHeaderViewModel(
            name: playlist.name,
            ownerName: playlist.owner.display_name,
            description: playlist.description,
            artworkURL: URL(string: playlist.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self
        
        return header
    }
    
}


// MARK: - Conforms the PlaylistHeaderCollectionReusableViewDelegate protcol
extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
    
}
