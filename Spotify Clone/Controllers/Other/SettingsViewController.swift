//
//  SettingsViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class SettingsViewController: UIViewController {

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    private var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        view.backgroundColor = .systemBackground
        
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        configureContrainsts()
    }

    private func configureModels() {
        sections.append(
            Section(title: "Profile", options: [
                Option(title: "View Your Profile", handler: { [weak self] in
                    DispatchQueue.main.async {
                        self?.viewProfile()
                    }
                })
            ])
        )
        
        sections.append(
            Section(title: "Account", options: [
                Option(title: "Sign Out", handler: { [weak self] in
                    DispatchQueue.main.async {
                        self?.signOut()
                    }
                })
            ])
        )
    }
    
    private func viewProfile() {
        let profileVC = ProfileViewController()
        profileVC.title = "Profile"
        profileVC.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func signOut() {
        
    }
    
    private func configureContrainsts() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
}


// MARK: - Confirm UITableViewDelegate and UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.text = sections[indexPath.section].options[indexPath.row].title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
}
