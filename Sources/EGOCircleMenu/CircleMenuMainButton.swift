//
//  CircleMenuMainButton.swift
//  CircleMenu
//
//  Created by Pavel Chehov on 08/11/2018.
//

import UIKit
import Lottie
import PromiseKit

public class CircleMenuMainButton: BasicCircleMenuButton {
	
	internal static let size 		= 52
	private let animationViewSize 	= 24
	private let startScale: CGFloat = 0.85
	private let endScale: CGFloat 	= 1.0
	private let scaleDuration 		= 0.1
	
	private let openAnimationKey 	= "hamburger-open"
	private let closeAnimationKey 	= "hamburger-close"
	
	private var openAnimationView 	= AnimationView()
	private var closeAnimationView 	= AnimationView()
	private var keypaths = [
		AnimationKeypath(keypath: "line1.Rectangle 1.Fill 1.Color"),
		AnimationKeypath(keypath: "line2.Rectangle 1.Fill 1.Color"),
		AnimationKeypath(keypath: "line3.Rectangle 1.Fill 1.Color")
	]
	private var colorValueProvider: ColorValueProvider?
	public let id = 100
	public private(set) var isOpen: Bool = false
	
	public var unfocusedIconColor: UIColor? {
		didSet {
			colorValueProvider = ColorValueProvider(unfocusedIconColor!.lottieColorValue)
			for keypath in keypaths {
				openAnimationView.setValueProvider(colorValueProvider!, keypath: keypath)
				closeAnimationView.setValueProvider(colorValueProvider!, keypath: keypath)
			}
		}
	}
	
	public convenience init() {
		self.init(frame: .zero)
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		let mainButtonAnimationView = UIView()
		mainButtonAnimationView.frame = CGRect(
			x: (Self.size - animationViewSize) / 2,
			y: (Self.size - animationViewSize) / 2,
			width: animationViewSize,
			height: animationViewSize
		)
		mainButtonAnimationView.backgroundColor = UIColor.clear
		
		// Open animation
		Animation.loadFromBundle(openAnimationKey) { [weak self] animation in
			self?.openAnimationView.animation = animation
		}
		openAnimationView.isHidden = false
		openAnimationView.frame = mainButtonAnimationView.bounds
		mainButtonAnimationView.addSubview(openAnimationView)
		
		// Close animation
		Animation.loadFromBundle(closeAnimationKey) { [weak self] animation in
			self?.closeAnimationView.animation = animation
		}
		closeAnimationView.isHidden = true
		closeAnimationView.frame = mainButtonAnimationView.bounds
		mainButtonAnimationView.addSubview(closeAnimationView)
		
		mainButtonAnimationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mainButtonAnimationViewOnTap)))
		
		backgroundColor = UIColor.white
		addSubview(mainButtonAnimationView)
		//self.addTarget(self, action: #selector(toggle), for: .touchUpInside)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func mainButtonAnimationViewOnTap() {
		sendActions(for: .touchUpInside)
	}
	
	@objc internal func toggle() {
		animateScale()
		if isOpen {
			closeAnimationView.play { finish in
				self.closeAnimationView.isHidden = true
				self.openAnimationView.isHidden = false
				self.closeAnimationView.stop()
			}
			isOpen.toggle()
		} else {
			openAnimationView.play { finish in
				self.openAnimationView.isHidden = true
				self.closeAnimationView.isHidden = false
				self.openAnimationView.stop()
			}
			isOpen.toggle()
		}
	}
	
	private func animateScale() {
		UIView.animate(
			withDuration: scaleDuration,
			animations: {
				self.transform = CGAffineTransform.init(scaleX: self.startScale, y: self.startScale)
			},
			completion: { b in
				UIView.animate(
					withDuration: self.scaleDuration,
					animations: {
						self.transform = CGAffineTransform.init(scaleX: self.endScale, y: self.endScale)
					}
				)
			}
		)
	}
	
}
