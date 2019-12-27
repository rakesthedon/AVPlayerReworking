//
//  VideoTableViewCell.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import UIKit
import AVKit

final class VideoTableViewCell: UITableViewCell {

	var viewModel: VideoPlayerViewModel?

	var playerView: VideoPlayerView?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		let playerView = VideoPlayerView(frame: .zero)
		self.playerView = playerView
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(playerView)
		playerView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			playerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
			playerView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
			playerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			playerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func config(with viewModel: VideoPlayerViewModel) {
		playerView?.config(with: viewModel)
		playerView?.play()
	}
}
