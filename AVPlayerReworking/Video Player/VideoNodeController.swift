//
//  VideoNodeController.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-27.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import AsyncDisplayKit
import GoogleInteractiveMediaAds

final class VideoNodeController: ASNodeController<VideoNode> {

	private let viewModel: VideoPlayerViewModel
	let playerNode: VideoNode

	private var contentPlayhead: IMAAVPlayerContentPlayhead?
	private var adsLoader: IMAAdsLoader?
	private var adsManager: IMAAdsManager?
	private var didPlayAd: Bool = false

	private static let kTestAppAdTagUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&" +
	"iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&" +
	"gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&" +
	"cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="

	override var node: VideoNode {
		return playerNode
	}

	init(viewModel: VideoPlayerViewModel) {
		self.viewModel = viewModel
		self.playerNode = VideoNode(viewModel: viewModel)
		super.init()

		playerNode.videoNode.delegate = self
	}

	func play() {
		playerNode.play()
	}

	func pause() {
		adsManager?.pause()
		playerNode.pause()
	}

	func stopPlayback(options: AVAudioSession.SetActiveOptions = []) {
		try? AVAudioSession.sharedInstance().setActive(false, options: options)
		try? AVAudioSession.sharedInstance().setCategory(.ambient)

		NotificationCenter.default.post(Notification(name: AVPlayer.shouldResetPlayerContext))
	}

	func destroyAdContext() {
		adsManager?.pause()
		adsManager?.destroy()
		adsLoader = nil
		contentPlayhead = nil
	}
}

private extension VideoNodeController {

	func prepareForPlayback() {
		try? AVAudioSession.sharedInstance().setCategory(.playback)
		try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
	}

	func setupAdPlayer() {
		guard let player = playerNode.player else { return }
		contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
	}

	func setupAdsLoader() {
		let settings = IMASettings()
		settings.enableBackgroundPlayback = false
		settings.disableNowPlayingInfo = true
		adsLoader = IMAAdsLoader(settings: settings)
		adsLoader?.delegate = self
	}

	func requestAds() {
		guard let contentPlayhead = contentPlayhead, node.isNodeLoaded else { return }
		let adDisplayContainer = IMAAdDisplayContainer(adContainer: node.view)

		let request = IMAAdsRequest(
			adTagUrl: Self.kTestAppAdTagUrl,
			adDisplayContainer: adDisplayContainer,
			contentPlayhead: contentPlayhead,
			userContext: nil)
		request?.continuousPlayback = true
		adsLoader?.requestAds(with: request)
	}

	func registerNotificationObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNuke), name: AVPlayer.shouldResetPlayerContext, object: nil)
	}

	@objc func didReceiveNuke(notification: Notification) {
	}
}

extension VideoNodeController: IMAAdsLoaderDelegate {
	func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
		adsManager = adsLoadedData?.adsManager
		adsManager?.delegate = self
		adsManager?.volume = viewModel.muted ? 0 : 1

		let adsRenderingSettings = IMAAdsRenderingSettings()
		adsRenderingSettings.webOpenerPresentingController = UIApplication.shared.keyWindow?.rootViewController

		adsManager?.initialize(with: adsRenderingSettings)
	}

	func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
		print("error...")
	}
}

extension VideoNodeController: IMAAdsManagerDelegate {

	func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
		playerNode.pause()
	}

	func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
		adsManager?.destroy()
		play()
	}

	func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
		switch event.type {
		case .LOADED:
			adsManager?.start()
		case .COMPLETE:
			didPlayAd = true
			play()
		default:
			return
		}
	}

	func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
		print(error.description)
	}
}

extension VideoNodeController: ASVideoNodeDelegate {

	func videoNode(_ videoNode: ASVideoNode, shouldChangePlayerStateTo state: ASVideoNodePlayerState) -> Bool {
		print("switch to : \(state.rawValue)")
		switch state {
		case .playing:
			prepareForPlayback()
			guard viewModel.shouldDisplayAdd && !didPlayAd else { return true }

			setupAdPlayer()
			setupAdsLoader()
			requestAds()

			return false
		case .finished:
			stopPlayback(options: .notifyOthersOnDeactivation)
			return true
		default:
			return true
		}
	}
}
