//
//  FeaturedPlaylistCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 19/01/2022.
//

import UIKit
import SDWebImage

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 1
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let contentSize = contentView.frame

        creatorNameLabel.sizeToFit()
        creatorNameLabel.frame = CGRect(
            x: 5,
            y: contentSize.height - creatorNameLabel.frame.height,
            width: contentSize.width - 10,
            height: creatorNameLabel.frame.height
        )
        
        playlistNameLabel.sizeToFit()
        playlistNameLabel.frame = CGRect(
            x: 5,
            y: contentSize.height - creatorNameLabel.frame.height - playlistNameLabel.frame.height - 5,
            width: contentSize.width - 10,
            height: playlistNameLabel.frame.height
        )
        
        let imageSize = playlistNameLabel.frame.minY - 10
        playlistCoverImageView.frame = CGRect(
            x: (contentSize.width - imageSize) / 2.0,
            y: 5,
            width: imageSize,
            height: imageSize
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playlistCoverImageView.image = nil
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
    }
    
    public func configure(with viewModel: FeaturedPlaylistCellViewModel) {
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
    }
    
}
