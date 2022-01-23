//
//  SearchResultsViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController {

    // MARK: - Properties
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        
        return tableView
    }()
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var sections = [SearchSection]()
    private var filteredSections = [SearchSection]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        view.addSubview(tableView)
        tableView.register(
            SearchResultDefaultTableViewCell.self,
            forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier
        )
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }

    
    // MARK: - Methods
    
    public func update(with results: [SearchResult]) {        
        self.sections = [
            SearchSection(title: SearchScope.albums.rawValue, results: results.filter {
                switch $0 {
                    case .album:
                        return true
                    default:
                        return false
                }
            }),
            SearchSection(title: SearchScope.artists.rawValue, results: results.filter {
                switch $0 {
                    case .artist:
                        return true
                    default:
                        return false
                }
            }),
            SearchSection(title: SearchScope.playlists.rawValue, results: results.filter {
                switch $0 {
                    case .playlist:
                        return true
                    default:
                        return false
                }
            }),
            SearchSection(title: SearchScope.songs.rawValue, results: results.filter {
                switch $0 {
                    case .track:
                        return true
                    default:
                        return false
                }
            }),
        ]
        self.filteredSections = sections
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    public func filtering(by searchScope: SearchScope) {
        if searchScope == .all {
            self.filteredSections = sections
        } else {
            self.filteredSections = sections.filter({ SearchScope(rawValue: $0.title) == searchScope })
        }
        
        tableView.reloadData()
        tableView.isHidden = filteredSections.isEmpty
    }
    
}


// MARK: - Conforms the UITableViewDelegate protocol
extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = filteredSections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
    
}


// MARK: - Conforms the UITableViewDataSource protocol
extension SearchResultsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = filteredSections[indexPath.section].results[indexPath.row]
        
        switch result {
            // Album
            case .album(let album):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                    for: indexPath
                ) as? SearchResultSubtitleTableViewCell else {
                    return UITableViewCell()
                }
                
                let viewModel = SearchResultSubtitleTableViewCellViewModel(
                    title: album.name,
                    subtitle: album.artists.first?.name ?? "",
                    imageURL: URL(string: album.images.first?.url ?? "")
                )
                cell.configure(with: viewModel)
                
                return cell
                
            // Artist
            case .artist(let artist):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultDefaultTableViewCell.identifier,
                    for: indexPath
                ) as? SearchResultDefaultTableViewCell else {
                    return UITableViewCell()
                }
                
                let viewModel = SearchResultDefaultTableViewCellViewModel(
                    title: artist.name,
                    imageURL: URL(string: artist.images?.first?.url ?? "")
                )
                cell.configure(with: viewModel)
                
                return cell
                
            // Playlist
            case .playlist(let playlist):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                    for: indexPath
                ) as? SearchResultSubtitleTableViewCell else {
                    return UITableViewCell()
                }
                
                let viewModel = SearchResultSubtitleTableViewCellViewModel(
                    title: playlist.name,
                    subtitle: playlist.owner.display_name,
                    imageURL: URL(string: playlist.images.first?.url ?? "")
                )
                cell.configure(with: viewModel)
                
                return cell
                
            // Track
            case .track(let track):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                    for: indexPath
                ) as? SearchResultSubtitleTableViewCell else {
                    return UITableViewCell()
                }
                
                let viewModel = SearchResultSubtitleTableViewCellViewModel(
                    title: track.name,
                    subtitle: track.artists.first?.name ?? "",
                    imageURL: URL(string: track.album?.images.first?.url ?? "")
                )
                cell.configure(with: viewModel)
                
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredSections[section].title
    }
    
}
