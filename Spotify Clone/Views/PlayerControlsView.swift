//
//  PlayerControlsView.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 25/01/2022.
//

import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView)
}

final class PlayerControlsView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: PlayerControlsViewDelegate?
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 1
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        slider.tintColor = .blue
        
        return slider
    }()
    
    private let controlButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(
            createControlImage(withSystemName: "backward.fill"),
            for: .normal
        )
        
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(
            createControlImage(withSystemName: "pause.fill"),
            for: .normal
        )
        
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(
            createControlImage(withSystemName: "forward.fill"),
            for: .normal
        )
        
        return button
    }()
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        clipsToBounds = true
        
        // testing
        nameLabel.text = "This is my favorite song"
        subtitleLabel.text = "Drake (feat. Some Other Artists)"
        
        // Add subiews
        addSubview(rootStackView)
        rootStackView.addArrangedSubview(nameLabel)
        rootStackView.addArrangedSubview(subtitleLabel)
        rootStackView.addArrangedSubview(volumeSlider)
        rootStackView.addArrangedSubview(controlButtonsStackView)
        controlButtonsStackView.addArrangedSubview(previousButton)
        controlButtonsStackView.addArrangedSubview(playPauseButton)
        controlButtonsStackView.addArrangedSubview(nextButton)
        
        // Add control buttons' actions
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(didTapPrevious), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        
        // Configure subviews' constraints
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }
    
    @objc private func didTapPlayPause(_ sender: UIButton) {
        delegate?.playerControlsViewDidTapPlayPauseButton(self)
    }

    @objc private func didTapPrevious(_ sender: UIButton) {
        delegate?.playerControlsViewDidTapBackwardButton(self)
    }
    
    @objc private func didTapNext(_ sender: UIButton) {
        delegate?.playerControlsViewDidTapForwardButton(self)
    }
    
}


// MARK: - Generates Control Image (UIImage)
extension PlayerControlsView {
    
    private static func createControlImage(withSystemName systemName: String) -> UIImage? {
        return UIImage(
            systemName: systemName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 34,
                weight: .regular
            )
        )
    }
    
}
