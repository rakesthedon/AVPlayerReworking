//
//  VideoGalleryViewModel.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import Foundation

final class VideoCellViewModel {

	let url: URL
	let muted: Bool = true

	var videoPlayerViewModel: VideoPlayerViewModel {
		return VideoPlayerViewModel(url: url, muted: false, shouldDisplayAdd: true)
	}

	init(url: URL) {
		self.url = url
	}
}

final class VideoPlayerViewModel {

	let url: URL
	var muted: Bool
	let shouldDisplayAdd: Bool

	init(url: URL, muted: Bool, shouldDisplayAdd: Bool) {
		self.url = url
		self.muted = muted
		self.shouldDisplayAdd = shouldDisplayAdd
	}
}

final class VideoGalleryViewModel {

	var didAddItem: (([VideoCellViewModel]) -> Void)?

	private var items: [VideoCellViewModel]

	init() {
		items = []
	}

	func numberOfItems() -> Int {
		return items.count
	}

	func items(at index: Int) -> VideoCellViewModel {
		assert(index < items.count)
		return items[index]
	}

	func loadItems() {
		DispatchQueue.global().async {
			let items = VideoGalleryViewModel.loadSamples()
			DispatchQueue.main.async { [weak self] in
				let viewModels = items.compactMap { VideoCellViewModel(url: $0) }
				self?.items.append(contentsOf: viewModels)
				self?.didAddItem?(viewModels)
			}
		}
	}
}


private extension VideoGalleryViewModel {

	static func loadSamples() -> [URL] {
		guard
			let sampleURL = Bundle.main.url(forResource: "sample", withExtension: "json"),
			let data = try? Data(contentsOf: sampleURL),
			let sample = try? JSONDecoder().decode([URL].self, from: data) else { return [] }
		return sample
	}
}
