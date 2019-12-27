//
//  VideoViewController.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import UIKit
import AVKit
import GoogleInteractiveMediaAds

final class VideoViewController: UIViewController {

	private let viewModel: VideoPlayerViewModel

	private var playerView: VideoPlayerView? {
		return view as? VideoPlayerView
	}

	private var contentPlayhead: IMAAVPlayerContentPlayhead?
	private var adsLoader: IMAAdsLoader?
	private var adsManager: IMAAdsManager?

	private static let kTestAppAdTagUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&" +
	"iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&" +
	"gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&" +
	"cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="

	init(viewModel: VideoPlayerViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = VideoPlayerView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
		navigationItem.rightBarButtonItem = closeButton
		viewModel.muted = false
		playerView?.config(with: viewModel)
		setupAdPlayer()
		setupAdsLoader()
		requestAds()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		stopPlayback(options: .notifyOthersOnDeactivation)
	}
}

private extension VideoViewController {

	func prepareForPlayback() {
		try? AVAudioSession.sharedInstance().setCategory(.playback)
		try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
	}

	func stopPlayback(options: AVAudioSession.SetActiveOptions = []) {
		playerView?.pause()
		try? AVAudioSession.sharedInstance().setActive(false, options: options)
		try? AVAudioSession.sharedInstance().setCategory(.ambient)

		NotificationCenter.default.post(Notification(name: AVPlayer.shouldResetPlayerContext))
	}

	func setupAdPlayer() {
		guard let player = playerView?.player else { return }
		contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
	}

	func setupAdsLoader() {
		let settings = IMASettings()
		settings.enableBackgroundPlayback = true
		adsLoader = IMAAdsLoader(settings: settings)
		adsLoader?.delegate = self
	}

	func requestAds() {
		guard let contentPlayhead = contentPlayhead else { return }
		let adDisplayContainer = IMAAdDisplayContainer(adContainer: view)

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
		playerView?.reset()
	}

	@objc func close() {
		adsManager?.destroy()
		dismiss(animated: true)
	}
}

extension VideoViewController: IMAAdsLoaderDelegate {
	func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
		adsManager = adsLoadedData?.adsManager
		adsManager?.delegate = self
		adsManager?.volume = viewModel.muted ? 0 : 1

		let adsRenderingSettings = IMAAdsRenderingSettings()
		adsRenderingSettings.webOpenerPresentingController = self

		adsManager?.initialize(with: adsRenderingSettings)
	}

	func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
		print("error...")
	}
}

extension VideoViewController: IMAAdsManagerDelegate {
	func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
		playerView?.pause()
	}

	func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
		adsManager?.destroy()
		play()
	}


	func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
		switch event.type {
		case .LOADED:
			prepareForPlayback()
			adsManager?.start()

		default:
			return
		}
	}

	func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
		print(error.description)
	}

	func play() {
		playerView?.play()
	}
}
