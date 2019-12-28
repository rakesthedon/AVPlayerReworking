//
//  VideoNode.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-27.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import AsyncDisplayKit

final class VideoNode: ASDisplayNode {

	let videoNode: ASVideoNode
	let viewModel: VideoPlayerViewModel

	var player: AVPlayer? {
		return videoNode.player
	}

	init(viewModel: VideoPlayerViewModel) {
		self.viewModel = viewModel
		self.videoNode = ASVideoNode()
		super.init()

		let asset = AVAsset(url: viewModel.url)
		videoNode.asset = asset
		automaticallyManagesSubnodes = true
	}

	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		videoNode.style.minSize = constrainedSize.min
		videoNode.style.maxSize = constrainedSize.max
		return ASWrapperLayoutSpec(layoutElement: videoNode)
	}

	func pause() {
		videoNode.pause()
	}

	func play() {
		videoNode.play()
	}
}
