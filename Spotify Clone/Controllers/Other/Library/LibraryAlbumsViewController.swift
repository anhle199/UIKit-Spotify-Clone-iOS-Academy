//
//  LibraryAlbumsViewController.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 12/02/2022.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    private var observer: NSObjectProtocol?
    
    private var albums = [Album]()
    
    private let noAlbumsView: ActionLabelView = {
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
        
        observer = NotificationCenter.default.addObserver(
            forName: .albumSavedNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.fetchData()
            }
        )
    }
    
    private func setupViews() {
        view.addSubview(noAlbumsView)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        noAlbumsView.delegate = self
        noAlbumsView.configure(
            with: .init(
                text: "You have not saved albums yet.",
                actionTitle: "Browse"
            )
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            noAlbumsView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            noAlbumsView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            noAlbumsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAlbumsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    private func fetchData() {
        albums.removeAll()
        
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error):
                    print("ERROR - getCurrentUserAlbums: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI() {
        if albums.isEmpty {
            tableView.isHidden = true
            noAlbumsView.isHidden = false
        } else {
            // show table of playlists
            tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - ActionLabelViewDelegate
extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}


// MARK: - UITableViewDelegate
extension LibraryAlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        
        let albumVC = AlbumViewController(album: albums[indexPath.row])
        navigationController?.pushViewController(albumVC, animated: true)
    }
}


// MARK: - UITableViewDataSource
extension LibraryAlbumsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultSubtitleTableViewCell.identifier,
            for: indexPath
        ) as? SearchResultSubtitleTableViewCell
        else {
            return UITableViewCell()
        }
        
        let album = albums[indexPath.row]
        cell.configure(
            with: .init(
                title: album.name,
                subtitle: album.artists.first?.name ?? "-",
                imageURL: URL(string: album.images.first?.url ?? "")
            )
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
