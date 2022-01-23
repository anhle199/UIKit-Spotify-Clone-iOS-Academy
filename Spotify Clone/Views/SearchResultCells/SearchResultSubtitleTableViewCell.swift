//
//  SearchResultSubtitleTableViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 24/01/2022.
//

import UIKit
import SDWebImage

class SearchResultSubtitleTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultSubtitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 3
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let verticalPadding: CGFloat = 5.0
        let horizontalPadding: CGFloat = 10.0
        let contentSize = contentView.frame
        let imageSize = contentSize.height - verticalPadding * 2
        
        iconImageView.frame = CGRect(
            x: horizontalPadding,
            y: verticalPadding,
            width: imageSize,
            height: imageSize
        )
        
        
        let labelHeight = contentSize.height / 2
        
        label.frame =  CGRect(
            x: iconImageView.frame.maxX + horizontalPadding,
            y: 0,
            width: contentSize.width - iconImageView.frame.maxX - horizontalPadding - 5,
            height: labelHeight
        )
        subtitleLabel.frame =  CGRect(
            x: iconImageView.frame.maxX + horizontalPadding,
            y: label.frame.maxY,
            width: contentSize.width - iconImageView.frame.maxX - horizontalPadding - 5,
            height: labelHeight
        )
    }
    
    public func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel) {
        label.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(
            with: viewModel.imageURL,
            placeholderImage: UIImage(systemName: "photo"),
            completed: nil
        )
    }
    
}
