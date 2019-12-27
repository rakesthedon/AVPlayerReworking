//
//  AppDelegate.swift
//  AVPlayerReworking
//
//  Created by Yannick Jacques on 2019-12-26.
//  Copyright © 2019 Yannick Jacques. All rights reserved.
//

import UIKit
import GoogleInteractiveMediaAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		try? AVAudioSession.sharedInstance().setCategory(.ambient)
		window = UIWindow()
		window?.rootViewController = VideoGalleryViewController()
		window?.makeKeyAndVisible()

		return true
	}
}

