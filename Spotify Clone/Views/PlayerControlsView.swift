//
//  PlayerControlsView.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 25/01/2022.
//

import UIKit
import AVFoundation

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

struct PlayerControlsViewViewModel {
    let songName: String?
    let subtitle: String?
}

final class PlayerControlsView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: PlayerControlsViewDelegate?
    
    private var isPlaying = true
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let labelsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 2
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
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
            PlayerControlsView.createControlImage(withSystemName: "backward.fill"),
            for: .normal
        )
        
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(
            PlayerControlsView.createPlayPauseIcon(isPlaying: true),
            for: .normal
        )
        
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(
            PlayerControlsView.createControlImage(withSystemName: "forward.fill"),
            for: .normal
        )
        
        return button
    }()
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        clipsToBounds = true
        
        // Add subiews
        addSubview(rootStackView)
        rootStackView.addArrangedSubview(labelsView)
        rootStackView.addArrangedSubview(volumeSlider)
        rootStackView.addArrangedSubview(controlButtonsStackView)
        labelsView.addSubview(nameLabel)
        labelsView.addSubview(subtitleLabel)
        controlButtonsStackView.addArrangedSubview(previousButton)
        controlButtonsStackView.addArrangedSubview(playPauseButton)
        controlButtonsStackView.addArrangedSubview(nextButton)
        
        // Add control buttons' actions
        volumeSlider.addTarget(self, action: #selector(didSlideSlider), for: .valueChanged)
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
            
            nameLabel.topAnchor.constraint(equalTo: labelsView.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
        ])
    }
    
    @objc private func didSlideSlider(_ slider: UISlider) {
        delegate?.playerControlsView(self, didSlideSlider: slider.value)
    }
    
    @objc private func didTapPlayPause() {
        delegate?.playerControlsViewDidTapPlayPauseButton(self)
        self.isPlaying = !isPlaying
        
        // update icon
        playPauseButton.setImage(
            PlayerControlsView.createPlayPauseIcon(isPlaying: isPlaying),
            for: .normal
        )
    }

    @objc private func didTapPrevious() {
        delegate?.playerControlsViewDidTapBackwardButton(self)
    }
    
    @objc private func didTapNext() {
        delegate?.playerControlsViewDidTapForwardButton(self)
    }
    
    func configure(with viewModel: PlayerControlsViewViewModel) {
        nameLabel.text = viewModel.songName
        subtitleLabel.text = viewModel.subtitle
    }
    
    func updateStatusOfPlayPauseButton(withIsPlaying isPlaying: Bool) {
        if self.isPlaying != isPlaying {
            self.isPlaying = isPlaying
            
            playPauseButton.setImage(
                PlayerControlsView.createPlayPauseIcon(isPlaying: isPlaying),
                for: .normal
            )
        }
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
    
    private static func createPlayPauseIcon(isPlaying: Bool) -> UIImage? {
        return createControlImage(withSystemName: isPlaying ? "pause.fill" : "play.fill")
    }
    
}
