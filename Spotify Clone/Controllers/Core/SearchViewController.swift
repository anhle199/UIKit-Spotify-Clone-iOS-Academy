//
//  SearchViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    private let searchController: UISearchController = {
        let searchVC = UISearchController(
            searchResultsController: SearchResultsViewController()
        )
        searchVC.searchBar.placeholder = "Songs, Artists, Albums"
        searchVC.searchBar.searchBarStyle = .minimal
        searchVC.definesPresentationContext = true
        
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
        
        // configures SearchController
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        // configures CollectionView
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    
        // configure contraints for all subviews
        configureConstraints()
        
        // fetches a list of categories
        fetchAllCategories()
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
                        print("ERROR: \(error.localizedDescription)")
                }
            }
        }
    }
    
}


// MARK: - Conforms the SearchResultsViewControllerDelegate protocol
extension SearchViewController: SearchResultsViewControllerDelegate {
    
    func didTapResult(_ result: SearchResult) {
        switch result {
            case .album(let model):
                let albumVC = AlbumViewController(album: model)
                navigationController?.pushViewController(albumVC, animated: true)
                
            case .artist(_/*let model*/):
                break
            case .playlist(let model):
                let playlistVC = PlaylistViewController(playlist: model)
                navigationController?.pushViewController(playlistVC, animated: true)
                
            case .track(_/*let model*/):
                break
        }
    }
    
}
