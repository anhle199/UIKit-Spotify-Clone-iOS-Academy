//
//  GenreCollectionViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 22/01/2022.
//

import UIKit

class GenreCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    static let identifier = "GenreCollectionViewCell"
    
    private let imageView: UIImageView = {
        let image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 50,
                weight: .regular
            )
        )
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        
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
        let horizontalLabelPadding: CGFloat = 10.0
        
        NSLayoutConstraint.activate([
            // position: top-left
            // width: a quarter of contentView's width
            // height: a quarter of contentView's height
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            
            // position: bottom
            // width: equal to contentView's width
            // height: a half of contentView's height
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalLabelPadding),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalLabelPadding),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
        ])
    }
    
    public func configure(with title: String) {
        label.text = title
        contentView.backgroundColor = colors.randomElement()
    }
    
}
