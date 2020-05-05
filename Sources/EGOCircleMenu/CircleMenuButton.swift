//
//  CircleMenuButton.swift
//  CircleMenu
//
//  Created by Pavel Chehov on 08/11/2018.
//

import UIKit

public class CircleMenuButton: BasicCircleMenuButton {
	
	internal var isClicked = false {
		didSet {
			guard let model = model, model.hasChildren else { return }
			
			backgroundColor 		= isClicked ? focusedBackgroundColor : unfocusedBackgroundColor
			imageView?.tintColor 	= isClicked ? focusedIconColor : unfocusedIconColor
		}
	}
	private var positions: [CGPoint]?
	private let padding: CGFloat = 14
	private var oldPosition: CGPoint? = CGPoint.zero
	
	internal static let size: Double = 52
	
	internal var indicator: CircleButtonIndicator?
	
	internal var model: CircleMenuItemModel? {
		didSet {
			if let model = model {
				setImage(model.imageSource, for: .normal)
				isHidden = false
			} else {
				isHidden = true
			}
			if let indicator = indicator {
				indicator.isHidden = !(model?.hasChildren ?? false)
			}
		}
	}
	
	internal var position: CGPoint? = CGPoint.zero {
		didSet {
			oldPosition = position
			if let position = position {
				frame = CGRect(x: position.x, y: position.y, width: CGFloat(Self.size), height: CGFloat(Self.size))
				let positionIndex = positions?.firstIndex(of: position)
				isUserInteractionEnabled = positionIndex != 4 && positionIndex != 0
			}
		}
	}
	
	internal var focusedBackgroundColor: UIColor? {
		didSet {
			if isClicked { backgroundColor = focusedBackgroundColor }
		}
	}
	
	internal var unfocusedBackgroundColor: UIColor? {
		didSet {
			if !isClicked { backgroundColor = unfocusedBackgroundColor }
		}
	}
	
	internal var focusedIconColor: UIColor? {
		didSet {
			if isClicked { imageView?.tintColor = focusedIconColor }
		}
	}
	
	internal var unfocusedIconColor: UIColor? {
		didSet {
			if !isClicked { imageView?.tintColor = unfocusedIconColor }
		}
	}
	
	internal var positionIndex: Int? {
		return positions?.firstIndex(of: position!)
	}
	
	override public var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				if isClicked {
					imageView?.tintColor = focusedIconColor
				}
			} else {
				if !isClicked {
					imageView?.tintColor = unfocusedIconColor
				}
			}
		}
	}
	
	public convenience init() {
		self.init(frame: CGRect.zero)
	}
	
	public convenience init(positions: [CGPoint]){
		self.init()
		self.positions = positions
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		tintColor = UIColor.black
		imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
		backgroundColor = UIColor.white
		
		adjustsImageWhenHighlighted = false
		addTarget(self, action: #selector(toggle), for: .touchUpInside)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	internal func resetPosition() {
		position = oldPosition
	}
	
	@objc internal func toggle() {
		guard let model = model, model.hasChildren else { return }
		
		isClicked = !isClicked
	}
	
}
