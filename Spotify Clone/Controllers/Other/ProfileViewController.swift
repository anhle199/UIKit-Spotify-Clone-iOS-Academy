//
//  ProfileViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        fetchProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func fetchProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch (result) {
                case .success(let model):
                    self?.updateUI(with: model)
                case .failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        
        // configure table models
        models.append("Full Name: \(model.display_name)")
        models.append("Email Address: \(model.email)")
        models.append("User ID: \(model.id)")
        models.append("Plan: \(model.product.capitalized)")
        
        makeTableHeader(with: model.images.first?.url)
        
        tableView.reloadData()
    }
    
    private func makeTableHeader(with urlString: String?) {
        let headerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: tableView.frame.width,
                height: tableView.frame.width / 1.5
            )
        )
        
        let imageSize = headerView.frame.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.contentMode = .scaleAspectFill
        imageView.center = headerView.center
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = tableView.frame.width / 6
        headerView.addSubview(imageView)
        
        // loads image
        if let urlString = urlString, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, completed: nil)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        
        tableView.tableHeaderView = headerView
    }
    
    private func failedToGetProfile() {
        let label = UILabel()
        label.text = "Failed to load profile."
        
        view.addSubview(label)
        label.center = view.center
    }

}


// MARK: - Confirm UITableViewDelegate and UITableViewDataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.text = models[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentConfiguration = contentConfiguration
        cell.selectionStyle = .none
        
        return cell
    }

}
