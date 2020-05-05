//
//  BundleExtension.swift
//  EGOCircleMenu
//
//  Created by BARDON Rémi on 05/05/2020.
//

import Foundation

extension Bundle {
	
	static var pod: Bundle? {
		if let path = Self.main.path(forResource: "EGOCircleMenu", ofType: "bundle") {
			return Self(path: path)
		} else {
			return nil
		}
	}
	
	static var podOrMain: Bundle {
		return Self.pod ?? Self.main
	}
	
}
