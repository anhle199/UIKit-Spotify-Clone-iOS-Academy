//
//  AlbumCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 22/01/2022.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "AlbumCollectionViewCell"
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1
        
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
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        // Setup constaints for all components
        let verticalPadding: CGFloat = 5.0
        let horizontalPadding: CGFloat = verticalPadding * 2
        
        NSLayoutConstraint.activate([
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            trackNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding),
            artistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
        ])
    }
    
    public func configure(with viewModel: AlbumCollectionViewCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
    
}
