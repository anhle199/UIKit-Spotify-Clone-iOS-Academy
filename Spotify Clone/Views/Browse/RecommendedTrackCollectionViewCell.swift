//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 19/01/2022.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RecommendedTrackCollectionViewCell"
    
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
        imageView.layer.cornerRadius = 2
        
        return imageView
    }()
    
    private let trackNameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        return view
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
        label.numberOfLines = 0
        
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
        contentView.addSubview(horizontalStackView)

        horizontalStackView.addArrangedSubview(albumCoverImageView)
        horizontalStackView.addArrangedSubview(verticalStackView)

        verticalStackView.addArrangedSubview(trackNameView)
        verticalStackView.addArrangedSubview(artistNameLabel)
        
        trackNameView.addSubview(trackNameLabel)

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

            trackNameLabel.topAnchor.constraint(equalTo: trackNameView.topAnchor),
            trackNameLabel.trailingAnchor.constraint(equalTo: trackNameView.trailingAnchor),
            trackNameLabel.leadingAnchor.constraint(equalTo: trackNameView.leadingAnchor),
            trackNameLabel.heightAnchor.constraint(lessThanOrEqualTo: trackNameView.heightAnchor),
        ])
    }
    
    public func configure(with viewModel: RecommendedTrackCellViewModel) {
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
    
}
