//
//  ViewController.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import UIKit
import AVKit

class VideoGalleryViewController: UITableViewController {

	private let viewModel: VideoGalleryViewModel

	init() {
		self.viewModel = VideoGalleryViewModel()

		super.init(style: .plain)

		viewModel.didAddItem = { [weak self] _ in
			self?.tableView?.reloadData()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: "VideoCell")
		registerNotificationObservers()
		viewModel.loadItems()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems()
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
		let videoCell = cell as? VideoTableViewCell
		let item = viewModel.items(at: indexPath.row)
		item.muted = true
		videoCell?.config(with: item)
		return cell
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return view.frame.width
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let viewModel = self.viewModel.items(at: indexPath.row)
		let videoViewController = VideoViewController(viewModel: viewModel)
		let navigationController = UINavigationController(rootViewController: videoViewController)
		present(navigationController, animated: true)
	}
}

private extension VideoGalleryViewController {

	func registerNotificationObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNuke), name: AVPlayer.shouldResetPlayerContext, object: nil)
	}

	@objc func didReceiveNuke() {
		tableView.reloadData()
	}
}
