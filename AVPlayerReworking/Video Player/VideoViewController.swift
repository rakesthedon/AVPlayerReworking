//
//  VideoViewController.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import UIKit
import AVKit
import AsyncDisplayKit
import GoogleInteractiveMediaAds

final class VideoViewController: ASViewController<VideoNode> {

	override var isBeingDismissed: Bool {
		return navigationController?.isBeingDismissed ?? parent?.isBeingDismissed ?? presentingViewController?.isBeingDismissed ?? super.isBeingDismissed
	}

	private let viewModel: VideoPlayerViewModel

	private let videoNodeController: VideoNodeController
//	private var playerNode: VideoNode { return videoNodeController.playerNode }

	init(viewModel: VideoPlayerViewModel) {
		viewModel.muted = false
		self.viewModel = viewModel
		self.videoNodeController = VideoNodeController(viewModel: viewModel)
		let playerNode = self.videoNodeController.node
		super.init(node: playerNode)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		videoNodeController.play()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		if isBeingDismissed == true {
			videoNodeController.pause()
			videoNodeController.destroyAdContext()
			videoNodeController.stopPlayback(options: .notifyOthersOnDeactivation)
		}
	}
}
