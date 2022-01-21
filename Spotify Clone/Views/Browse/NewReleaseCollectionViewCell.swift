//
//  NewReleaseCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 19/01/2022.
//

import UIKit
import SDWebImage

class NewReleaseCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "NewReleaseCollectionViewCell"
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    private let nameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        return view
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
    
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0
    
        return label
    }()
    
    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
    
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        contentView.addSubview(horizontalStackView)

        horizontalStackView.addArrangedSubview(albumCoverImageView)
        horizontalStackView.addArrangedSubview(verticalStackView)

        verticalStackView.addArrangedSubview(nameView)
        verticalStackView.addArrangedSubview(numberOfTracksLabel)

        nameView.addSubview(albumNameLabel)
        nameView.addSubview(artistNameLabel)


        // Setup constaints for all components
        let padding: CGFloat = 5.0
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            // Because horizontalStackView's distribution is fill proportionally,
            // so the height of albumCoverImageView is equal to the height of horizontalStackView
            albumCoverImageView.widthAnchor.constraint(equalTo: albumCoverImageView.heightAnchor),

            albumNameLabel.topAnchor.constraint(equalTo: nameView.topAnchor),
            albumNameLabel.trailingAnchor.constraint(equalTo: nameView.trailingAnchor),
            albumNameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            albumNameLabel.heightAnchor.constraint(lessThanOrEqualTo: nameView.heightAnchor, multiplier: 2.0 / 3.0),

            artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor),
            artistNameLabel.trailingAnchor.constraint(equalTo: nameView.trailingAnchor),
            artistNameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            artistNameLabel.heightAnchor.constraint(lessThanOrEqualTo: nameView.heightAnchor, multiplier: 1.0 / 3.0),
        ])
    }
    
    public func configure(with viewModel: NewReleaseCellViewModel) {
        albumCoverImageView.sd_setImage(with: viewModel.arkworkURL, completed: nil)
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
    }
    
}
