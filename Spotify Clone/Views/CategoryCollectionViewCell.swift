//
//  CategoryCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 22/01/2022.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    static let identifier = "GenreCollectionViewCell"
    
    private static let musicPlaceholderImage = UIImage(
        systemName: "music.quarternote.3",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 50,
            weight: .regular
        )
    )
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = CategoryCollectionViewCell.musicPlaceholderImage
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        
        return label
    }()

    private let colors: [UIColor] = [
        .systemRed,
        .systemGreen,
        .systemBlue,
        .systemPink,
        .systemPurple,
        .systemOrange,
        .systemYellow,
        .systemTeal,
        .darkGray,
    ]
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemPink
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        // Add subviews
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        // Configure constraints
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    
    private func configureConstraints() {
        let horizontalPadding: CGFloat = 10.0
        
        NSLayoutConstraint.activate([
            // position: top-left
            // width: equal to its height
            // height: a quarter of contentView's height minus by 5
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: horizontalPadding),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            imageView.heightAnchor.constraint(
                equalTo: contentView.heightAnchor,
                multiplier: 0.5,
                constant: -horizontalPadding / 2.0
            ),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            // position: bottom
            // width: equal to contentView's width
            // height: a half of contentView's height
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
        ])
    }
    
    public func configure(with viewModel: CategoryCollectionViewCellViewModel) {
        label.text = viewModel.name
        imageView.sd_setImage(
            with: viewModel.artworkURL,
            placeholderImage: CategoryCollectionViewCell.musicPlaceholderImage,
            completed: nil
        )
        contentView.backgroundColor = colors.randomElement()
    }
    
}
