//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 21/01/2022.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Properties
    
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    private let labelBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        
        let image = UIImage(
            systemName: "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 30,
                weight: .regular
            )
        )
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addAllSubviews()
        configureConstraints()
        
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    
    @objc private func didTapPlayAll(_ sender: UIButton) {
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
    private func addAllSubviews() {
        addSubview(imageView)
        addSubview(labelBackgroundView)
        addSubview(playAllButton)
        
        labelBackgroundView.addSubview(nameLabel)
        labelBackgroundView.addSubview(descriptionLabel)
        labelBackgroundView.addSubview(ownerLabel)
    }
    
    private func configureConstraints() {
        let padding: CGFloat = 10.0
        let buttonSize: CGFloat = 60.0
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: padding * 1.5),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 5.0 / 9.0),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            labelBackgroundView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
            labelBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            labelBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            nameLabel.topAnchor.constraint(equalTo: labelBackgroundView.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelBackgroundView.trailingAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelBackgroundView.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: padding),
            descriptionLabel.trailingAnchor.constraint(equalTo: labelBackgroundView.trailingAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: labelBackgroundView.leadingAnchor),

            ownerLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: padding),
            ownerLabel.trailingAnchor.constraint(equalTo: labelBackgroundView.trailingAnchor),
            ownerLabel.leadingAnchor.constraint(equalTo: labelBackgroundView.leadingAnchor),
            
            playAllButton.widthAnchor.constraint(equalToConstant: buttonSize),
            playAllButton.heightAnchor.constraint(equalToConstant: buttonSize),
            playAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding * 2),
            playAllButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding * 2),
        ])
    }
    
    func configure(with viewModel: PlaylistHeaderViewModel) {
        nameLabel.text = viewModel.name
        ownerLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.description
        imageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
    
}
