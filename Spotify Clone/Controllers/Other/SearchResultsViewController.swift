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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        
        return tableView
    }()
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var sections = [SearchSection]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        view.addSubview(tableView)
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
            SearchSection(title: "Albums", results: results.filter {
                switch $0 {
                    case .album:
                        return true
                    default:
                        return false
                }
            }),
            SearchSection(title: "Artists", results: results.filter {
                switch $0 {
                    case .artist:
                        return true
                    default:
                        return false
                }
            }),
            SearchSection(title: "Playlists", results: results.filter {
                switch $0 {
                    case .playlist:
                        return true
                    default:
                        return false
                }
            }),
            SearchSection(title: "Songs", results: results.filter {
                switch $0 {
                    case .track:
                        return true
                    default:
                        return false
                }
            }),
        ]
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
}


// MARK: - Conforms the UITableViewDelegate protocol
extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
    
}


// MARK: - Conforms the UITableViewDataSource protocol
extension SearchResultsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch result {
            case .album(let model):
                cell.textLabel?.text = model.name
            case .artist(let model):
                cell.textLabel?.text = model.name
            case .playlist(let model):
                cell.textLabel?.text = model.name
            case .track(let model):
                cell.textLabel?.text = model.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
}
