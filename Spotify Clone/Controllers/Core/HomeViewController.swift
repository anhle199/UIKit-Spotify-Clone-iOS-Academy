//
//  HomeViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleaseCellViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
    
    var title: String {
        switch self {
        case .newReleases:
            return "New Released Albums"
        case .featuredPlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}

class HomeViewController: UIViewController {

    // MARK: - Properties
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout {
                sectionIndex, _ -> NSCollectionLayoutSection? in
                
                return HomeViewController.makeSectionLayout(section: sectionIndex)
            }
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        
        return collectionView
    }()
    
    private let alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Loading", message: nil, preferredStyle: .alert)
        
        return alertController
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isUserInteractionEnabled = false

        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    private var newAlbums = [Album]()
    private var playlists = [Playlist]()
    private var tracks = [AudioTrack]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        
        
        // Configures loading view
        configureLoadingView()
        
        // Configures collection view
        configureCollectionView()
        
        // Starts loading view
        startLoadingView()
        
        // Fetches data
        fetchData()
    }
    
    // MARK: - Methods
    
    private func configureLoadingView() {
        alertController.view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            alertController.view.heightAnchor.constraint(equalToConstant: 80),
    
            spinner.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor, constant: 15),
        ])
    }
    
    private func startLoadingView() {
        spinner.startAnimating()
        present(alertController, animated: true, completion: nil)
    }
    
    private func stopLoadingView() {
        alertController.dismiss(animated: true, completion: nil)
        spinner.stopAnimating()
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        // Register cells and header view
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        collectionView.register(
            NewReleaseCollectionViewCell.self,
            forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier
        )
        collectionView.register(
            FeaturedPlaylistCollectionViewCell.self,
            forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier
        )
        collectionView.register(
            RecommendedTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier
        )
        collectionView.register(
            TitleHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        // Configure contraints for collection view
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        
        var newReleasesResponse: NewReleasesResponse?
        var featuredPlaylistsResponse: FeaturedPlaylistsResponse?
        var recommendationsResponse: RecommendationsResponse?
        
        // New Releases
        group.enter()
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            
            switch (result) {
            case .success(let model):
                newReleasesResponse = model
            case .failure(let error):
                print("ERROR - getNewReleases: \(error.localizedDescription)")
            }
        }
        
        // Featured Playlists
        group.enter()
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            
            switch (result) {
            case .success(let model):
                featuredPlaylistsResponse = model
            case .failure(let error):
                print("ERROR - getFeaturedPlaylists: \(error.localizedDescription)")
            }
        }
        
        // Recommendations
        group.enter()
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

                APICaller.shared.getRecommendations(genres: seedGenres) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    
                    switch (recommendedResult) {
                    case .success(let model):
                        recommendationsResponse = model
                    case .failure(let error):
                        print("ERROR - getRecommendations: \(error.localizedDescription)")
                    }
                }

            case .failure(let error):
                print("ERROR - getAvailableGenreSeeds: \(error.localizedDescription)")
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let newAlbums = newReleasesResponse?.albums.items,
                  let playlists = featuredPlaylistsResponse?.playlists.items,
                  let tracks = recommendationsResponse?.tracks
            else {
                return
            }
            
            self?.configureModels(
                newAlbums: newAlbums,
                playlists: playlists,
                tracks: tracks
            )
        }
    }
    
    private func configureModels(
        newAlbums: [Album],
        playlists: [Playlist],
        tracks: [AudioTrack]
    ) {
        
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        
        // NewReleaseCellViewModel
        sections.append(.newReleases(
            viewModels: newAlbums.compactMap { album in
                return NewReleaseCellViewModel(
                    name: album.name,
                    arkworkURL: URL(string: album.images.first?.url ?? ""),
                    numberOfTracks: album.total_tracks,
                    artistName: album.artists.first?.name ?? "-"
                )
            }
        ))
        
        // FeaturedPlaylistCellViewModel
        sections.append(.featuredPlaylists(
            viewModels: playlists.compactMap { playlist in
                return FeaturedPlaylistCellViewModel(
                    name: playlist.name,
                    artworkURL: URL(string: playlist.images.first?.url ?? ""),
                    creatorName: playlist.owner.display_name
                )
            }
        ))
        
        // RecommendedTrackCellViewModel
        sections.append(.recommendedTracks(
            viewModels: tracks.compactMap { track in
                return RecommendedTrackCellViewModel(
                    name: track.name,
                    artworkURL: URL(string: track.album?.images.first?.url ?? ""),
                    artistName: track.artists.first?.name ?? "-"
                )
            }
        ))
        
        // Trigger colectionView to reload data
        collectionView.reloadData()
        stopLoadingView()
        collectionView.isHidden = false
    }

    @objc func didTapSettings(_ sender: UIBarButtonItem) {
        let profileVC = SettingsViewController()
        profileVC.title = "Settings"
        profileVC.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
}

// MARK: - Section Layouts
extension HomeViewController {
    
    private enum GroupDimension {
        case vertical
        case horizontal
    }
    
    static func makeSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            return makeNewReleasesSectionLayout()
        case 1:
            return makeFeaturedPlaylistsSectionLayout()
        case 2:
            return makeRecommendedTracksSectionLayout()
        default:
            return makeDefaultSectionLayout(
                groupDimension: .horizontal,
                groupLayoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)
                ),
                itemCount: 1
            )
        }
    }
    
    private static func makeNewReleasesSectionLayout() -> NSCollectionLayoutSection {
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
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(390)
            ),
            subitem: item,
            count: 3
        )
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .absolute(390)
            ),
            subitem: verticalGroup,
            count: 1
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        
        // Header
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        return section
    }
    
    private static func makeFeaturedPlaylistsSectionLayout() -> NSCollectionLayoutSection {
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
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(200),
                heightDimension: .absolute(400)
            ),
            subitem: item,
            count: 2
        )
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(200),
                heightDimension: .absolute(400)
            ),
            subitem: verticalGroup,
            count: 1
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.orthogonalScrollingBehavior = .continuous
        
        // Header
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        return section
    }
    
    private static func makeRecommendedTracksSectionLayout() -> NSCollectionLayoutSection {
        // Section
        let section = makeDefaultSectionLayout(
            groupDimension: .horizontal,
            groupLayoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(80)
            ),
            itemCount: 1
        )
        
        return section
    }
    
    private static func makeDefaultSectionLayout(
        groupDimension: GroupDimension,
        groupLayoutSize: NSCollectionLayoutSize,
        itemCount: Int
    ) -> NSCollectionLayoutSection {
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
        var group: NSCollectionLayoutGroup
        
        switch (groupDimension) {
        case .horizontal:
            group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupLayoutSize,
                subitem: item,
                count: itemCount
            )
        case .vertical:
            group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupLayoutSize,
                subitem: item,
                count: itemCount
            )
        }
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        
        // Header
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        return section
    }
    
}


// MARK: - Conforms the UICollectionViewDelegate protocol
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let section = sections[indexPath.section]
        switch section {
            case .newReleases:
                let albumVC = AlbumViewController(album: newAlbums[indexPath.row])
                navigationController?.pushViewController(albumVC, animated: true)
                
            case .featuredPlaylists:
                let playlistVC = PlaylistViewController(playlist: playlists[indexPath.row])
                navigationController?.pushViewController(playlistVC, animated: true)
                
            case .recommendedTracks:
                break
        }
    }
    
}


// MARK: - Conforms the UICollectionViewDataSource protocol
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]

        switch type {
        case .newReleases(let viewModels):
            return viewModels.count
        case .featuredPlaylists(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]

        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: viewModels[indexPath.row])
            return cell

        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            )  as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: viewModels[indexPath.row])
            return cell

        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath
            )  as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? TitleHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        
        header.configure(with: sections[indexPath.section].title)
        return header
    }
    
}
