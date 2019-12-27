//
//  Notification+Extension.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import AVKit

extension AVPlayer {
	static let shouldResetPlayerContext: Notification.Name = .init("ShouldResetPlayerContext")
	static let shouldPauseAllPlayers: Notification.Name = .init("ShouldPauseAllPlayers")
}
