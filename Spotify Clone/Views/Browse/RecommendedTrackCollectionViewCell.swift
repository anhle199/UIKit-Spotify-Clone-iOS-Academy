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
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 2
        
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let contentSize = contentView.frame
        
        albumCoverImageView.frame = CGRect(
            x: 5,
            y: 5,
            width: contentSize.height - 10,
            height: contentSize.height - 10
        )
 
        trackNameLabel.frame = CGRect(
            x: albumCoverImageView.frame.maxX + 5,
            y: 5,
            width: contentSize.width - albumCoverImageView.frame.maxX - 5,
            height: contentSize.height / 2.0
        )
        
        artistNameLabel.frame = CGRect(
            x: albumCoverImageView.frame.maxX + 5,
            y: contentSize.height - artistNameLabel.frame.height - 5,
            width: contentSize.width - albumCoverImageView.frame.maxX - 5,
            height: contentSize.height / 2.0
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        albumCoverImageView.image = nil
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    public func configure(with viewModel: RecommendedTrackCellViewModel) {
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
    
}
