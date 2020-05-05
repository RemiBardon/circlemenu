//
//  UIColorExtension.swift
//  CircleMenu
//
//  Created by Pavel Chehov on 13/11/2018.
//

import UIKit
import Lottie

extension UIColor {
	
	convenience init(red: Int, green: Int, blue: Int) {
		assert((0...255).contains(red), 	"Invalid red component")
		assert((0...255).contains(green), 	"Invalid green component")
		assert((0...255).contains(blue), 	"Invalid blue component")
		
		self.init(
			red: 	CGFloat(red)	/ 255.0,
			green: 	CGFloat(green)	/ 255.0,
			blue: 	CGFloat(blue)	/ 255.0,
			alpha: 	1.0
		)
	}
	
}
