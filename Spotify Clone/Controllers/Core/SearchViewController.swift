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
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // configures SearchController
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        // configures CollectionView
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            GenreCollectionViewCell.self,
            forCellWithReuseIdentifier: GenreCollectionViewCell.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    
        // configure contraints for all subviews
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        
        print(query)
        // Calls search api
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
        print("Did selected at \(indexPath)")
    }
}


// MARK: - Conforms the UICollectionViewDataSource protocol
extension SearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GenreCollectionViewCell.identifier,
            for: indexPath
        ) as? GenreCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: "Rock")
        return cell
    }
    
}
