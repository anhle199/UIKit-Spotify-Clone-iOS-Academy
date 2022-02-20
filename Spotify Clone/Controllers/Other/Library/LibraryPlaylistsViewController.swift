//
//  LibraryPlaylistsViewController.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 12/02/2022.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {

    var selectionHandler: ((Playlist) -> Void)?
    
    private var playlists = [Playlist]()
    
    private let noPlaylistsView: ActionLabelView = {
        let actionView = ActionLabelView()
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.isHidden = true
        
        return actionView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier
        )
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupViews()
        setupConstraints()
        fetchData()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }
    
    private func setupViews() {
        view.addSubview(noPlaylistsView)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        noPlaylistsView.delegate = self
        noPlaylistsView.configure(
            with: .init(
                text: "You don't have any playlists yet.",
                actionTitle: "Create"
            )
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            noPlaylistsView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            noPlaylistsView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            noPlaylistsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPlaylistsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    private func fetchData() {
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case .failure(let error):
                    print("ERROR - getCurrentUserPlaylists: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            tableView.isHidden = true
            noPlaylistsView.isHidden = false
        } else {
            // show table of playlists
            tableView.reloadData()
            noPlaylistsView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

    func showCreatePlaylistAlert() {
        let alert = UIAlertController(
            title: "New Playlist",
            message: "Enter playlist name",
            preferredStyle: .alert
        )
        
        // Add a text field to alert
        alert.addTextField { textField in
            textField.placeholder = "Playlist name..."
        }
        
        // Add actions
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { action in
            guard let textField = alert.textFields?.first,
                  let playlistName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !playlistName.isEmpty
            else {
                return
            }
            
            APICaller.shared.createPlaylist(with: playlistName) { [weak self] success in
                if success {
                    self?.fetchData()
                } else {
                    print("ERROR - createPlaylist inside showCreatePlaylistAlert: Failed to create new playlist")
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
}


// MARK: - ActionLabelViewDelegate
extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}


// MARK: - UITableViewDelegate
extension LibraryPlaylistsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let playlist = playlists[indexPath.row]
        if let selectionHandler = selectionHandler {
            selectionHandler(playlist)
            dismiss(animated: true, completion: nil)  // dismiss selection of playlist view
        } else {
            let playlistVC = PlaylistViewController(playlist: playlist)
            playlistVC.isOwner = true
            
            navigationController?.pushViewController(playlistVC, animated: true)
        }
    }
}


// MARK: - UITableViewDataSource
extension LibraryPlaylistsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultSubtitleTableViewCell.identifier,
            for: indexPath
        ) as? SearchResultSubtitleTableViewCell
        else {
            return UITableViewCell()
        }
        
        let playlist = playlists[indexPath.row]
        cell.configure(
            with: .init(
                title: playlist.name,
                subtitle: playlist.owner.display_name,
                imageURL: URL(string: playlist.images.first?.url ?? "")
            )
        )
        
        // remove right chevron when selecting a playlist to add track to that
        if selectionHandler != nil {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
