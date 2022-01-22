//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 19/01/2022.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 2
        
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 2
        
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 1
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        // Setup constaints for all components
        let padding: CGFloat = 5.0
        let horizontalLabelPadding: CGFloat = padding * 2
        
        NSLayoutConstraint.activate([
            albumCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            albumCoverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            albumCoverImageView.widthAnchor.constraint(equalTo: albumCoverImageView.heightAnchor),

            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalLabelPadding),
            trackNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: horizontalLabelPadding),
            
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalLabelPadding),
            artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            artistNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: horizontalLabelPadding),
        ])
    }
    
    public func configure(with viewModel: RecommendedTrackCellViewModel) {
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
    
}
