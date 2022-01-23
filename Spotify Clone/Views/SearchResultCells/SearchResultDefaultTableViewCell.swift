//
//  SearchResultDefaultTableViewCell.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 24/01/2022.
//

import UIKit
import SDWebImage

class SearchResultDefaultTableViewCell: UITableViewCell {

    static let identifier = "SearchResultDefaultTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
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
        iconImageView.layer.cornerRadius = imageSize / 2.0
        iconImageView.layer.masksToBounds = true

        label.frame =  CGRect(
            x: iconImageView.frame.maxX + horizontalPadding,
            y: verticalPadding,
            width: contentSize.width - iconImageView.frame.maxX - horizontalPadding - 5,
            height: imageSize
        )
    }
    
    public func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        label.text = viewModel.title
        iconImageView.sd_setImage(
            with: viewModel.imageURL,
            placeholderImage: UIImage(systemName: "photo"),
            completed: nil
        )
    }
    
}
