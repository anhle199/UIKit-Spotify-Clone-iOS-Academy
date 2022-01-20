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
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = contentView.frame.width
        let height = contentView.frame.height
        let imageSize = contentView.frame.height - 10
        let albumLabelSize = albumNameLabel.sizeThatFits(
            CGSize(
                width: width - imageSize - 10,
                height: height - 10
            )
        )
        let albumLabelHeight = min(60, albumLabelSize.height)
        
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        
        
        // Configure frames
        albumCoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        albumNameLabel.frame = CGRect(
            x: imageSize + 15,
            y: 5,
            width: width - imageSize - 20,
            height: albumLabelHeight
        )
        
        artistNameLabel.frame = CGRect(
            x: imageSize + 15,
            y: albumNameLabel.frame.height + 5,
            width: width - imageSize - 20,
            height: 30
        )
        
        numberOfTracksLabel.frame = CGRect(
            x: imageSize + 15,
            y: height - 44,
            width: width - imageSize - 20,
            height: 44
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        albumCoverImageView.image = nil
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
    }
    
    public func configure(with viewModel: NewReleaseCellViewModel) {
        albumCoverImageView.sd_setImage(with: viewModel.arkworkURL, completed: nil)
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
    }
    
}
