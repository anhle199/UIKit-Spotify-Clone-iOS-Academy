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
}

class HomeViewController: UIViewController {

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout {
                sectionIndex, _ -> NSCollectionLayoutSection? in
                
                return HomeViewController.makeSectionLayout(section: sectionIndex)
            }
        )
        
        return collectionView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        
        configureCollectionView()
        view.addSubview(spinner)
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
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
            viewModels: newAlbums.compactMap { playlist in
            return FeaturedPlaylistCellViewModel()
        }
        ))
        
        // RecommendedTrackCellViewModel
        sections.append(.recommendedTracks(
            viewModels: newAlbums.compactMap { track in
                return RecommendedTrackCellViewModel()
            }
        ))
        
        collectionView.reloadData()
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
            top: 2, leading: 2, bottom: 2, trailing: 2
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
            top: 2, leading: 2, bottom: 2, trailing: 2
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
            top: 2, leading: 2, bottom: 2, trailing: 2
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
        
        return section
    }
    
}


// MARK: - Conform UICollectionViewDelegate and UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
            
        case .featuredPlaylists(_):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            )  as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.backgroundColor = .blue
            return cell
            
        case .recommendedTracks(_):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath
            )  as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.backgroundColor = .orange
            return cell
        }
    }
    
}
