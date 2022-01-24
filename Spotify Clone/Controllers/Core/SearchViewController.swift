//
//  SearchViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

enum SearchScope: String, CaseIterable {
    case all = "All"
    case albums = "Albums"
    case artists = "Artists"
    case playlists = "Playlists"
    case songs = "Songs"
    
    init?(rawValue: String) {
        switch rawValue {
            case "All":
                self = .all
            case "Albums":
                self = .albums
            case "Artists":
                self = .artists
            case "Playlists":
                self = .playlists
            case "Songs":
                self = .songs
            default:
                return nil
        }
    }
}

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    private let searchController: UISearchController = {
        let searchVC = UISearchController(
            searchResultsController: SearchResultsViewController()
        )
        searchVC.searchBar.placeholder = "Songs, Artists, Albums"
        searchVC.searchBar.searchBarStyle = .minimal
        searchVC.definesPresentationContext = true
        searchVC.searchBar.autocapitalizationType = .none
        searchVC.searchBar.scopeButtonTitles = SearchScope.allCases.map({ $0.rawValue })
        
        return searchVC
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout {
                _, _  -> NSCollectionLayoutSection? in
                
                return SearchViewController.makeSectionLayout()
            }
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private var categories = [Category]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureSearchController()
        configureCollectionView()
        configureConstraints()
        
        fetchAllCategories()
    }
    
    private func configureSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    private func fetchAllCategories() {
        APICaller.shared.getAllCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let categories):
                        self?.categories = categories
                        self?.collectionView.reloadData()
                    case .failure(let error):
                        print("ERRRO - getAllCategories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}


// MARK: - Section Layout
extension SearchViewController {
    
    static private func makeSectionLayout() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        // Item's paddings
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 7,
            bottom: 2,
            trailing: 7
        )
        
        // Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(150)
            ),
            subitem: item,
            count: 2
        )
        
        // Group's paddings
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 0,
            bottom: 10,
            trailing: 0
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
}


// MARK: - Conforms the UICollectionViewDelegate protocol
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let categoryVC = CategoryViewController(category: categories[indexPath.row])
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}


// MARK: - Conforms the UICollectionViewDataSource protocol
extension SearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.row]
        let viewModel = CategoryCollectionViewCellViewModel(
            name: category.name,
            artworkURL: URL(string: category.icons.first?.url ?? "")
        )
        cell.configure(with: viewModel)
        
        return cell
    }
    
}


// MARK: - Conforms the UISearchBarDelegate protocol
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        
        resultsController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                    case.success(let results):
                        resultsController.update(with: results)
                    case .failure(let error):
                        print("ERROR - search: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let allScopes = searchBar.scopeButtonTitles,
              let selectedSearchScope = SearchScope(rawValue: allScopes[selectedScope])
        else {
            return
        }
        
        resultsController.filtering(by: selectedSearchScope)
    }
    
}


// MARK: - Conforms the SearchResultsViewControllerDelegate protocol
extension SearchViewController: SearchResultsViewControllerDelegate {
    
    func didTapResult(_ result: SearchResult) {
        switch result {
            case .album(let album):
                let albumVC = AlbumViewController(album: album)
                navigationController?.pushViewController(albumVC, animated: true)
                
            case .artist(_/*let artist*/):
                break
            case .playlist(let playlist):
                let playlistVC = PlaylistViewController(playlist: playlist)
                navigationController?.pushViewController(playlistVC, animated: true)
                
            case .track(let track):
            PlaybackPresenter.startPlayback(from: self, track: track)
        }
    }
    
}
