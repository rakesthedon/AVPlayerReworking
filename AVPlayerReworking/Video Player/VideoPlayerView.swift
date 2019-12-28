//
//  VideoPlayerView.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import UIKit
import AVKit

final class VideoPlayerView: UIView {

	var player: AVPlayer?

	var videoLayer: AVPlayerLayer? {
		return layer as? AVPlayerLayer
	}

	private var viewModel: VideoCellViewModel?

	override class var layerClass: AnyClass {
		return AVPlayerLayer.self
	}

	func config(with viewModel: VideoCellViewModel?) {
		guard let viewModel = viewModel else {
			videoLayer?.player = nil
			player = nil
			return
		}

		player = AVPlayer(url: viewModel.url)
		player?.allowsExternalPlayback = false
		player?.isMuted = viewModel.muted
		
		videoLayer?.player = player
		self.viewModel = viewModel
	}



	func play() {
		player?.play()
	}

	func pause() {
		player?.pause()
	}

	func destroy() {
		videoLayer?.player = nil
		player = nil
	}

	func reset() {
		destroy()
		config(with: viewModel)
	}

	@objc func didReceivePause(notification: Notification) {
		player?.pause()
	}
}
