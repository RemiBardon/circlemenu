//
//  AnimationExtension.swift
//  EGOCircleMenu
//
//  Created by BARDON Rémi on 05/05/2020.
//

import Lottie

extension Animation {
	
	fileprivate static func animationUrl(forKey key: String) -> URL? {
		URL(string: "https://raw.githubusercontent.com/ego-cms/circlemenu/master/EGOCircleMenu/Assets/\(key).json")
	}
	
	static func loadFromBundle(_ key: String, completion: @escaping DownloadClosure) {
		if let animation = Animation.named(key, bundle: .podOrMain) {
			// With CocoaPods, Assets are available
			completion(animation)
		} else if let url = Self.animationUrl(forKey: key) {
			// With Swift Package Manager, Assets are not available yet
			// Fetch asynchronously
			Animation.loadedFrom(url: url, closure: completion, animationCache: nil)
		} else {
			assertionFailure()
			completion(nil)
		}
	}
	
}
