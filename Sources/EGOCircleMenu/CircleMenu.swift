//
//  CircleMenu.swift
//  CircleMenu
//
//  Created by Pavel Chehov on 08/11/2018.
//

import UIKit
import PromiseKit

public class CircleMenu: UIView {
	
	// MARK: - Model
	
	///	* `.none` - Tapping on the blackout view does nothing
	///	* `.submenuOnly` - Tapping on the blackout view closes submenu if open, and does nothing otherwise
	///	* `.menuOnly` - Tapping on the blackout view closes menu if no submenu is open, and does nothing otherwise
	///	* `.all` - Tapping on the blackout view closes both submenu and menu if open, but one at a time (it takes two taps to close the menu if a submenu is open)
	///	* `.allAtTheSameTime` - Tapping on the blackout view closes both submenu and menu, at the same time. If a submenu is open or not, tapping on the blackout view closes the menu.
	public enum ClosingPossibility {
		case none, submenuOnly, menuOnly, all, allAtTheSameTime
	}
	
	// MARK: - Properties
	
	/// Sequence of the models for buttons
	public var circleMenuItems: [CircleMenuItemModel] = [] {
		willSet {
			precondition(
				newValue.count >= Self.minimumCountOfElements && newValue.count <= Self.maximumCountOfElements,
				"Source must contain \(Self.minimumCountOfElements) - \(Self.maximumCountOfElements) elements"
			)
		}
	}
	
	// MARK: - Elements Count
	
	private static let minimumCountOfElements = 3
	private static let maximumCountOfElements = 9
	private static let visibleCountOfElements = 5
	private static let maximumCountOfChildren = 5
	
	// MARK: Display configuration
	
	private let mainButtonPadding: Double 				= 15
	private let hintPadding: Double 					= 7
	private let submenuElementMargin: Double 			= 10
	private let submenuIndicatorMargin: Double 			= 15
	private let menuSize: Double 						= 300
	private let buttonPositionDistanceCoeff: Double 	= 130
	private let indicatorPositionDistanceCoeff: Double 	= 150
	private let radius: Double 							= 96
	
	// MARK: Colors
	
	/// Button's background color in the regular state
	public var unfocusedBackgroundColor: UIColor? {
		didSet {
			menuButtons.forEach { $0.unfocusedBackgroundColor = self.unfocusedBackgroundColor }
			mainButton.backgroundColor = unfocusedBackgroundColor
		}
	}
	
	/// Button's background color in the pressed state
	public var focusedBackgroundColor: UIColor? {
		didSet {
			menuButtons.forEach { $0.focusedBackgroundColor = self.focusedBackgroundColor }
			buttonIndicators.forEach { $0.backgroundColor = self.focusedBackgroundColor }
		}
	}
	
	/// Button's icon color in the regular state
	public var unfocusedIconColor: UIColor? {
		didSet {
			menuButtons.forEach { $0.unfocusedIconColor = self.unfocusedIconColor }
			mainButton.unfocusedIconColor = unfocusedIconColor
		}
	}
	
	/// Button's icon color in the pressed state
	public var focusedIconColor: UIColor? {
		didSet {
			menuButtons.forEach { $0.focusedIconColor = self.focusedIconColor }
		}
	}
	
	/// Background view color when menu is open
	public var blackoutColor: UIColor? {
		didSet {
			shadowView.backgroundColor = blackoutColor
		}
	}
	
	// MARK: Animations
	
	private let menuOpenButtonAnimationDuration = 0.05
	private let buttonMovementAnimationDuration = 0.1
	private let buttonHintAnimationDuration 	= 0.4
	private let showSubmenuDuration 			= 0.1
	
	// MARK: Helpful values
	
	private static let submenuButtonsStartTag = 500
	
	private static let _2degrees: Double 	= 0.0174533
	private static let _6degrees: Double 	= 0.10472
	private static let _45degrees: Double 	= 0.785398
	private static let _55degrees: Double 	= 0.959931
	private static let _360degrees: Double 	= 6.28
	
	// MARK: Subviews
	
	private var rootView: UIView?
	private let shadowView = UIView()
	private let buttonsAreaOnShadowView = UIView()
	private var menuButtonsView = UIView()
	
	// MARK: Buttons
	
	private let mainButton 			= CircleMenuMainButton()
	private var menuButtons 		= [CircleMenuButton]()
	private var buttonIndicators 	= [CircleButtonIndicator]()
	private var buttonPositions 	= [CGPoint]()
	private var indicatorPositions 	= [CGPoint]()
	
	// MARK: Gestures
	
	private lazy var panSwipe = UIPanGestureRecognizer(target: self, action: #selector(panAction))
	private var gestureAnalyzer: CircleMenuPanGestureAnalyzer?
	
	private lazy var shadowViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shadowViewTapped))
	
	/// Variable indicating what a tap on the blackout view should do. There are 5 possible cases explained below
	///	* `.none` - Tapping on the blackout view does nothing
	///	* `.submenuOnly` - Tapping on the blackout view closes submenu if open, and does nothing otherwise
	///	* `.menuOnly` - Tapping on the blackout view closes menu if no submenu is open, and does nothing otherwise
	///	* `.all` - Tapping on the blackout view closes both submenu and menu if open, but one at a time (it takes two taps to close the menu if a submenu is open)
	///	* `.allAtTheSameTime` - Tapping on the blackout view closes both submenu and menu, at the same time. If a submenu is open or not, tapping on the blackout view closes the menu.
	public var tappingShadowViewCloses: ClosingPossibility = .none
	
	// MARK: State variables
	
	private var isSubmenuOpen 	= false
	private var isHintShown 	= false
	
	private var isSwipeBlocked: Bool {
		return !mainButton.isOpen || circleMenuItems.count == Self.minimumCountOfElements || isSubmenuOpen
	}
	
	/// Variable containing the opened submenu if one is open, `nil` otherwise
	public private(set) var openedSubmenu: CircleMenuButton?
	
	// MARK: Delegate
	
	public var delegate: CircleMenuDelegate?
	
	// MARK: - Methods
	
	/// Attach the `CircleMenu` to a `UIViewController`
	/// - Parameter viewController: Target `UIViewController`
	public func attach(to viewController: UIViewController) {
		rootView = viewController.view
		let rootView = self.rootView!
		
		self.translatesAutoresizingMaskIntoConstraints = false
		
		shadowView.backgroundColor = UIColor.clear
		shadowView.isHidden = true
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		shadowViewTapGestureRecognizer.isEnabled = false
		shadowView.addGestureRecognizer(shadowViewTapGestureRecognizer)
		
		buttonsAreaOnShadowView.backgroundColor = UIColor.clear
		buttonsAreaOnShadowView.translatesAutoresizingMaskIntoConstraints = false
		
		self.backgroundColor = UIColor.clear
		
		gestureAnalyzer = CircleMenuPanGestureAnalyzer(view: rootView)
		rootView.addGestureRecognizer(panSwipe)
		
		menuButtonsView.backgroundColor = UIColor.clear
		menuButtonsView.clipsToBounds = false
		menuButtonsView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(menuButtonsView)
		self.addConstraints([
			menuButtonsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			menuButtonsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			menuButtonsView.topAnchor.constraint(equalTo: self.topAnchor),
			menuButtonsView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
		
		mainButton.translatesAutoresizingMaskIntoConstraints = false
		rootView.addSubview(shadowView)
		rootView.addSubview(self)
		shadowView.addSubview(buttonsAreaOnShadowView)
		mainButton.addTarget(self, action: #selector(mainButtonTouchUpInside), for: .touchUpInside)
		self.addSubview(mainButton)
		rootView.addConstraints([
			shadowView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
			shadowView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
			shadowView.topAnchor.constraint(equalTo: rootView.topAnchor),
			shadowView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
			
			buttonsAreaOnShadowView.trailingAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.trailingAnchor),
			buttonsAreaOnShadowView.bottomAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.bottomAnchor),
			buttonsAreaOnShadowView.widthAnchor.constraint(equalToConstant: CGFloat(menuSize)),
			buttonsAreaOnShadowView.heightAnchor.constraint(equalToConstant: CGFloat(menuSize*2)),
			
			self.heightAnchor.constraint(equalToConstant: CGFloat(menuSize)),
			self.widthAnchor.constraint(equalToConstant: CGFloat(menuSize)),
			self.bottomAnchor.constraint(
				equalTo: rootView.safeAreaLayoutGuide.bottomAnchor,
				constant: CGFloat(menuSize/2 - CircleMenuButton.size/2 - mainButtonPadding)
			),
			self.trailingAnchor.constraint(
				equalTo: rootView.safeAreaLayoutGuide.trailingAnchor,
				constant: CGFloat(menuSize/2 - CircleMenuButton.size/2 - mainButtonPadding)
			),
			
			mainButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			mainButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			mainButton.heightAnchor.constraint(equalToConstant: CGFloat(CircleMenuButton.size)),
			mainButton.widthAnchor.constraint(equalToConstant: CGFloat(CircleMenuButton.size))
		])
		
		mainButton.layer.cornerRadius = CGFloat(CircleMenuMainButton.size/2)
		
		fillButtonsPositions()
		createMenuButtons()
		fillIndicatorPositions()
		createMenuIndicators()
		updateAppearance()
	}
	
	private func fillButtonsPositions() {
		var startAngle 	= -Self._55degrees
		let endAngle 	= Self._360degrees + startAngle
		let diff 		= (endAngle - startAngle) / Double(Self.maximumCountOfElements)
		
		for _ in 0..<Self.visibleCountOfElements {
			let x = cos(startAngle) * radius + menuSize/2.0 - CircleMenuButton.size/2.0
			let y = sin(startAngle) * radius + menuSize/2.0 - CircleMenuButton.size/2.0
			buttonPositions.append(CGPoint(x: x, y: y))
			startAngle -= diff
		}
		
		fillLastButtonPosition()
	}
	
	private func fillLastButtonPosition() {
		let x = cos(Self._45degrees) * menuSize + menuSize/2.0 - CircleMenuButton.size/2.0
		let y = sin(Self._45degrees) * menuSize + menuSize/2.0 - CircleMenuButton.size/2.0
		buttonPositions.append(CGPoint(x: x, y: y))
	}
	
	private func fillIndicatorPositions() {
		var startAngle 	= -Self._55degrees
		let endAngle 	= Self._360degrees + startAngle
		let diff 		= (endAngle - startAngle) / Double(Self.maximumCountOfElements)
		
		for _ in 0..<Self.visibleCountOfElements {
			let x = cos(startAngle) * buttonPositionDistanceCoeff + menuSize / 2.0 - CircleButtonIndicator.size / 2.0
			let y = sin(startAngle) * buttonPositionDistanceCoeff + menuSize / 2.0 - CircleButtonIndicator.size / 2.0
			indicatorPositions.append(CGPoint(x: x, y: y))
			startAngle -= diff
		}
		
		fillLastIndicatorPosition()
	}
	
	private func fillLastIndicatorPosition() {
		let x = cos(Self._45degrees) * indicatorPositionDistanceCoeff + menuSize / 2.0 - CircleButtonIndicator.size / 2.0
		let y = sin(Self._45degrees) * indicatorPositionDistanceCoeff + menuSize / 2.0 - CircleButtonIndicator.size / 2.0
		indicatorPositions.append(CGPoint(x: x, y: y))
	}
	
	private func createMenuButtons() {
		let position = buttonPositions.last
		for _ in 0..<buttonPositions.count {
			let menuButton = CircleMenuButton(positions: buttonPositions)
			menuButton.addTarget(self, action: #selector(menuButtonTouchUpInside(_:)), for: .touchUpInside)
			menuButton.position = position
			menuButtonsView.insertSubview(menuButton, at: 0)
			menuButtons.append(menuButton)
		}
	}
	
	private func createMenuIndicators() {
		let position = indicatorPositions.last
		for i in 0..<indicatorPositions.count {
			let indicator = CircleButtonIndicator()
			indicator.position = position!
			menuButtons[i].indicator = indicator
			menuButtonsView.insertSubview(indicator, at: 0)
			buttonIndicators.append(indicator)
		}
	}
	
	private func setModelsForButtons() {
		menuButtons.forEach { $0.model = nil }
		switch circleMenuItems.count {
		case Self.minimumCountOfElements:
			setModelsForThreeButtons()
		case 4:
			setModelsForFourButtons()
		case let i where i > 4:
			setModelsForMoreThanFourButtons()
		default:
			break
		}
	}
	
	private func setModelsForThreeButtons() {
		var buttonIndex = 1
		for modelIndex in 0..<Self.minimumCountOfElements {
			menuButtons[buttonIndex].model = circleMenuItems[modelIndex]
			buttonIndex += 1
		}
	}
	
	private func setModelsForFourButtons() {
		for i in 0..<circleMenuItems.count {
			menuButtons[i].model = circleMenuItems[i]
		}
		menuButtons[4].model = circleMenuItems[0]
	}
	
	private func setModelsForMoreThanFourButtons() {
		for i in 0..<[circleMenuItems.count, menuButtons.count].min()! {
			menuButtons[i].model = circleMenuItems[i]
		}
	}
	
	@objc private func mainButtonTouchUpInside() {
		delegate?.menuItemSelected(id: mainButton.id)
		mainButton.isOpen ? closeMenu() : openMenu()
	}
	
	@objc private func panAction(recognizer: UIPanGestureRecognizer) {
		let possibleDirection = gestureAnalyzer?.getDirection(for: recognizer)
		
		guard let direction = possibleDirection, !isSwipeBlocked else { return }
		
		switch direction {
		case .left, .down:
			moveLeft()
		default:
			moveRight()
		}
	}
	
	@objc private func menuButtonTouchUpInside(_ button: CircleMenuButton) {
		if let model = button.model {
			delegate?.menuItemSelected(id: model.id!)
		}
		
		prepareSubmenuIfNeeded(invokedButton: button)
	}
	
	@objc private func onSubmenuTouchUpIside(_ button: CircleMenuButton) {
		delegate?.menuItemSelected(id: button.model!.id!)
	}
	
	/// Opens the menu
	@objc public func openMenu() {
		mainButton.toggle()
		shadowView.isHidden = false
		setModelsForButtons()
		
		setSwipeInteractions(enabled: false).cauterize()
		menuButtonsView.transform = CGAffineTransform(rotationAngle: CGFloat(-Self._6degrees))
		firstly {
			self.startOpenMenuAnimation()
		}.then {
			self.setButtonInteractions(enabled: false)
		}.then {
			self.startOpenSpringEffect(angle: -Self._6degrees)
		}.then {
			self.startHintAnimationIfNeeded()
		}.done {
			self.shadowViewTapGestureRecognizer.isEnabled = true
			self.setButtonInteractions(enabled: true).cauterize()
			self.setSwipeInteractions(enabled: true).cauterize()
		}.cauterize()
	}
	
	private func startOpenMenuAnimation() -> Promise<Void> {
		var resolver: Resolver<Void>?
		
		let promise = Promise { (seal: Resolver<Void>) in
			resolver = seal
		}
		
		let completion: (Bool) -> Void = { b in
			resolver?.fulfill(Void())
		}
		
		for i in 0..<Self.visibleCountOfElements {
			let delay = menuOpenButtonAnimationDuration * Double(i)
			for j in 0...i {
				let positionIndex = i - j
				if i == Self.visibleCountOfElements-1 && j == i {
					startMoveButtonAnimation(
						button: menuButtons[j],
						buttonPosition: buttonPositions[positionIndex],
						indicatorPosition: indicatorPositions[positionIndex],
						duration: menuOpenButtonAnimationDuration,
						delay: delay,
						completion: completion
					)
				} else {
					startMoveButtonAnimation(
						button: menuButtons[j],
						buttonPosition: buttonPositions[positionIndex],
						indicatorPosition: indicatorPositions[positionIndex],
						duration: menuOpenButtonAnimationDuration,
						delay: delay
					)
				}
			}
		}
		return promise
	}
	
	/// Closes the menu
	@objc public func closeMenu() {
		guard mainButton.isOpen else { return }
		
		mainButton.toggle()
		shadowViewTapGestureRecognizer.isEnabled = false
		shadowView.isHidden = true
		
		if let button = openedSubmenu {
			closeSubmenu(invokedButton: button).cauterize()
		}
		
		var promise: Promise<Void>?
		setSwipeInteractions(enabled: false).cauterize()
		for _ in 0..<menuButtons.count-1 {
			if let p = promise {
				promise = p.then { self.closeAwaitableAnimationStep() }
			} else {
				promise = closeAwaitableAnimationStep()
			}
		}
		setSwipeInteractions(enabled: true).cauterize()
	}
	
	private func closeAwaitableAnimationStep() -> Promise<Void> {
		return Promise { seal in
			var callbackSet = false
			for j in 0..<menuButtons.count {
				let positionIndex = menuButtons[j].positionIndex!
				
				if positionIndex == buttonPositions.count-1 { continue }
				
				let previousPositionIndex = positionIndex > 0 ? positionIndex-1 : buttonPositions.count-1
				if callbackSet {
					startMoveButtonAnimation(
						button: menuButtons[j],
						buttonPosition: buttonPositions[previousPositionIndex],
						indicatorPosition: indicatorPositions[previousPositionIndex],
						duration: menuOpenButtonAnimationDuration
					)
				} else {
					startMoveButtonAnimation(
						button: menuButtons[j],
						buttonPosition: buttonPositions[previousPositionIndex],
						indicatorPosition: indicatorPositions[previousPositionIndex],
						duration: menuOpenButtonAnimationDuration,
						completion: { b in seal.fulfill(Void()) }
					)
					callbackSet = true
				}
			}
		}
	}
	
	private func moveLeft() {
		firstly {
			self.moveLeftAnimation()
		}.then { _ in
			self.setButtonInteractions(enabled: false)
		}.then { _ in
			self.startMoveSpringEffect(angle: -Self._2degrees)
		}.then { _ in
			self.setButtonInteractions(enabled: true)
		}.cauterize()
	}
	
	private func moveLeftAnimation() -> Promise<Void> {
		return Promise { seal in
			let zeroButtonPositionModel = menuButtons.first { $0.position == buttonPositions[0] }?.model
			let indexOfZeroButtonPositionModel = circleMenuItems.firstIndex { $0.id == zeroButtonPositionModel?.id }!
			for i in 0..<menuButtons.count {
				let positionIndex = buttonPositions.firstIndex(of: menuButtons[i].position!)!
				let nextPositionIndex = positionIndex != buttonPositions.count-1 ? positionIndex+1 : 0
				if nextPositionIndex == 0 {
					let indexOfNextModel = indexOfZeroButtonPositionModel < circleMenuItems.count-1 ? indexOfZeroButtonPositionModel+1 : 0
					menuButtons[i].model = circleMenuItems[indexOfNextModel]
				}
				startMoveButtonAnimation(button: menuButtons[i], buttonPosition: buttonPositions[nextPositionIndex], indicatorPosition: indicatorPositions[nextPositionIndex], duration: buttonMovementAnimationDuration, completion: {b in seal.fulfill(Void())})
			}
		}
	}
	
	private func moveRight() {
		firstly {
			self.moveRightAnimation()
		}.then { _ in
			self.setButtonInteractions(enabled: false)
		}.then { _ in
			self.startMoveSpringEffect(angle: Self._2degrees)
		}.then { _ in
			self.setButtonInteractions(enabled: true)
		}.cauterize()
	}
	
	private func moveRightAnimation() -> Promise<Void> {
		return Promise { seal in
			let lastbuttonPositionModel = menuButtons.first {$0.position == buttonPositions[4]}?.model
			let indexOfLastButtonPositionModel = circleMenuItems.firstIndex{$0.id == lastbuttonPositionModel?.id}!
			for i in 0..<menuButtons.count {
				let positionIndex = menuButtons[i].positionIndex!
				let previousPositionIndex = positionIndex != 0 ? positionIndex-1 : buttonPositions.count-1
				if previousPositionIndex == 4 {
					let indexOfPreviousModel = indexOfLastButtonPositionModel > 0 ? indexOfLastButtonPositionModel-1 : circleMenuItems.count-1
					menuButtons[i].model = circleMenuItems[indexOfPreviousModel]
				}
				startMoveButtonAnimation(
					button: menuButtons[i],
					buttonPosition: buttonPositions[previousPositionIndex],
					indicatorPosition: indicatorPositions[previousPositionIndex],
					duration: buttonMovementAnimationDuration,
					completion: { b in seal.fulfill(Void()) }
				)
			}
		}
	}
	
	private func startOpenSpringEffect(angle: Double) -> Promise<Void> {
		var resolver: Resolver<Void>?
		let promise = Promise { (seal: Resolver<Void>) in
			resolver = seal
		}
		
		let leftAnimation = CASpringAnimation()
		leftAnimation.keyPath = "transform.rotation.z"
		leftAnimation.fromValue = angle
		leftAnimation.toValue = 0
		leftAnimation.repeatCount = 1
		leftAnimation.isRemovedOnCompletion = false
		leftAnimation.fillMode = .forwards
		leftAnimation.initialVelocity = 40
		leftAnimation.duration = 0.7
		leftAnimation.delegate = AnimationDelegate {
			self.menuButtonsView.transform = CGAffineTransform(rotationAngle: 0)
			self.menuButtonsView.layer.removeAllAnimations()
			resolver?.fulfill(Void())
		}
		menuButtonsView.layer.add(leftAnimation, forKey: nil)
		return promise
	}
	
	private func startMoveSpringEffect(angle: Double) -> Promise<Void> {
		return Promise { seal in
			let firstAnimation = CASpringAnimation()
			firstAnimation.keyPath = "transform.rotation.z"
			firstAnimation.fromValue = 0
			firstAnimation.toValue = angle
			firstAnimation.repeatCount = 1
			firstAnimation.isRemovedOnCompletion = false
			firstAnimation.fillMode = .forwards
			firstAnimation.initialVelocity = 80
			firstAnimation.duration = 0.2
			
			let secondAnimation = CASpringAnimation()
			secondAnimation.keyPath = "transform.rotation.z"
			secondAnimation.fromValue = angle
			secondAnimation.toValue = 0
			secondAnimation.isRemovedOnCompletion = false
			secondAnimation.fillMode = .forwards
			secondAnimation.initialVelocity = 70
			secondAnimation.duration = 0.6
			
			let firstId = String(Int.random(in: 0..<1000))
			let secondId = String(Int.random(in: 1000...2000))
			firstAnimation.delegate = AnimationDelegate {
				self.menuButtonsView.layer.add(secondAnimation, forKey: secondId)
			}
			secondAnimation.delegate = AnimationDelegate {
				self.menuButtonsView.layer.removeAnimation(forKey: firstId)
				self.menuButtonsView.layer.removeAnimation(forKey: secondId)
				seal.fulfill(Void())
			}
			menuButtonsView.layer.add(firstAnimation, forKey: firstId)
		}
	}
	
	private func prepareSubmenuIfNeeded(invokedButton: CircleMenuButton) {
		guard let model = invokedButton.model, model.hasChildren else { return }
		
		precondition(
			model.children.count <= Self.maximumCountOfChildren,
			"Submenu should contain no more than \(Self.maximumCountOfChildren) elements"
		)
		
		invokedButton.isUserInteractionEnabled = false
		setSwipeInteractions(enabled: false).cauterize()
		setButtonInteractions(enabled: false).cauterize()
		
		var promise: Promise<Void>?
		if isSubmenuOpen {
			if let button = openedSubmenu, button != invokedButton {
				// If another submenu is open
				
				// Close opened submenu
				promise = closeSubmenu(invokedButton: button)
				
				// Open new submenu
				let submenuButtons = prepareSubmenu(invokedButton: invokedButton, children: model.children)
				promise = promise?.then {
					self.openSubmenu(invokedButton: invokedButton, submenuButtons: submenuButtons)
				}
			} else {
				promise = closeSubmenu(invokedButton: invokedButton)
			}
		} else {
			let submenuButtons = prepareSubmenu(invokedButton: invokedButton, children: model.children)
			promise = openSubmenu(invokedButton: invokedButton, submenuButtons: submenuButtons)
		}
		promise = promise?.done {
			invokedButton.isUserInteractionEnabled = true
			self.setButtonInteractions(enabled: true).cauterize()
			self.setSwipeInteractions(enabled: true).cauterize()
		}
	}
	
	private func prepareSubmenu(invokedButton: CircleMenuButton, children: [CircleMenuItemModel]) -> [CircleMenuButton] {
		let convertedPosition = menuButtonsView.convert(invokedButton.position!, to: buttonsAreaOnShadowView)
		var xPosition = convertedPosition.x
		var yPosition = convertedPosition.y
		var submenuButtons = [CircleMenuButton]()
		let buttonPosition = buttonPositions.firstIndex(of: invokedButton.position!)
		if buttonPosition == 3 {
			xPosition = xPosition - CGFloat(CircleMenuButton.size) - CGFloat(submenuElementMargin)
			yPosition = yPosition + CGFloat(CircleMenuButton.size) + CGFloat(submenuElementMargin)
		}
		var j = Self.submenuButtonsStartTag
		for i in 0..<children.count {
			yPosition = yPosition - CGFloat(CircleMenuButton.size) - CGFloat(submenuElementMargin)
			let button = CircleMenuButton()
			button.model = children[i]
			button.frame = CGRect(
				x: xPosition,
				y: yPosition,
				width: CGFloat(CircleMenuButton.size),
				height: CGFloat(CircleMenuButton.size)
			)
			button.alpha = 0
			button.tag = j
			button.unfocusedBackgroundColor = self.unfocusedBackgroundColor ?? UIColor.white
			button.unfocusedIconColor = self.unfocusedIconColor ?? UIColor.black
			button.addTarget(self, action: #selector(onSubmenuTouchUpIside(_:)), for: .touchUpInside)
			submenuButtons.append(button)
			j += 1
		}
		return submenuButtons
	}
	
	private func openSubmenu(invokedButton: CircleMenuButton, submenuButtons: [CircleMenuButton]) -> Promise<Void> {
		if tappingShadowViewCloses == .none {
			sendViewToBack()
		}
		
		openedSubmenu = invokedButton
		isSubmenuOpen = true
		
		return Promise { seal in
			let convertedPosition = menuButtonsView.convert(invokedButton.position!, to: buttonsAreaOnShadowView)
			invokedButton.frame.resize(x: convertedPosition.x, y: convertedPosition.y)
			buttonsAreaOnShadowView.insertSubview(invokedButton, at: buttonsAreaOnShadowView.subviews.count)
			let indicator = invokedButton.indicator!
			indicator.isHidden = true
			let lastButtonFrame = submenuButtons.last!.frame
			indicator.frame.resize(
				x: lastButtonFrame.minX + lastButtonFrame.width/2 - indicator.frame.width/2,
				y: lastButtonFrame.minY - CGFloat(submenuIndicatorMargin)
			)
			buttonsAreaOnShadowView.insertSubview(indicator, at: buttonsAreaOnShadowView.subviews.count)
			
			var promise: Promise<Void>?
			for i in 0..<submenuButtons.count {
				buttonsAreaOnShadowView.addSubview(submenuButtons[i])
				if promise == nil {
					promise = startChangeAlphaAnimation(button: submenuButtons[i], alpha: 1, duration: self.showSubmenuDuration)
				} else {
					promise = promise?.then { _ in
						self.startChangeAlphaAnimation(button: submenuButtons[i], alpha: 1, duration: self.showSubmenuDuration)
					}
				}
			}
			promise?.done {
				invokedButton.indicator!.isHidden = false
				seal.fulfill(Void())
			}.cauterize()
		}
	}
	
	private func closeSubmenu(invokedButton: CircleMenuButton) -> Promise<Void> {
		if invokedButton.isClicked {
			invokedButton.toggle()
		}
		
		sendViewToFront()
		
		openedSubmenu = nil
		isSubmenuOpen = false
		
		return Promise { seal in
			invokedButton.resetPosition()
			invokedButton.indicator?.resetPosition()
			menuButtonsView.insertSubview(invokedButton, at: menuButtonsView.subviews.count)
			menuButtonsView.insertSubview(invokedButton.indicator!, at: menuButtonsView.subviews.count)
			invokedButton.isUserInteractionEnabled = false
			let submenuButtons = buttonsAreaOnShadowView.subviews
				.filter {$0.tag >= 0 && $0.tag <= Self.submenuButtonsStartTag + Self.maximumCountOfChildren && $0 is CircleMenuButton }
				.sorted { $0.tag > $1.tag }
			
			guard let buttons = submenuButtons as? [CircleMenuButton], !buttons.isEmpty else { return }
			
			invokedButton.indicator?.isHidden = true
			
			var promise = startChangeAlphaAnimation(button: buttons[0], alpha: 0, duration: showSubmenuDuration)
			for i in 1..<buttons.count {
				promise = promise.then { _ in
					self.startChangeAlphaAnimation(button: buttons[i], alpha: 0, duration: self.showSubmenuDuration)
				}
			}
			promise.done {
				invokedButton.indicator?.resetPosition()
				invokedButton.indicator?.isHidden = false
				buttons.forEach { b in
					b.removeFromSuperview()
					b.removeTarget(self, action: #selector(self.onSubmenuTouchUpIside), for: .touchUpInside)
				}
				invokedButton.isUserInteractionEnabled = true
				seal.fulfill(Void())
			}.cauterize()
		}
	}
	
	@objc func shadowViewTapped() {
		if let button = openedSubmenu {
			// If a submenu is opened
			switch tappingShadowViewCloses {
			case .submenuOnly, .all:
				closeSubmenu(invokedButton: button).cauterize()
			case .allAtTheSameTime:
				closeMenu()
			default:
				break
			}
		} else {
			switch tappingShadowViewCloses {
			case .menuOnly, .all, .allAtTheSameTime:
				closeMenu()
			default:
				break
			}
		}
	}
	
	private func startChangeAlphaAnimation(button: CircleMenuButton, alpha: CGFloat, duration: Double) -> Promise<Void> {
		return Promise { seal in
			self.shadowViewTapGestureRecognizer.isEnabled = false
			UIView.animate(withDuration: duration, animations: {
				button.alpha = alpha
			}, completion: { b in
				self.shadowViewTapGestureRecognizer.isEnabled = true
				seal.fulfill(Void())
			})
		}
	}
	
	private func startHintAnimationIfNeeded() -> Promise<Void> {
		return Promise { seal in
			guard let invokedButton = menuButtons.first(where: { $0.positionIndex == 1 }),
				isHintShown == false,
				invokedButton.model!.hasChildren
			else {
				seal.fulfill(Void())
				return
			}
			
			self.shadowViewTapGestureRecognizer.isEnabled = false
			
			var hintViews = [UIView]()
			for _ in 0..<2 {
				let hintView = UIView(frame: invokedButton.frame)
				hintView.backgroundColor = self.unfocusedBackgroundColor
				hintView.layer.cornerRadius = invokedButton.bounds.height / 2
				hintView.layer.shadowColor = UIColor.black.cgColor
				hintView.layer.shadowOffset = CGSize(width: 0, height: 1)
				hintView.layer.shadowRadius = 1
				hintView.layer.shadowOpacity = 0.2
				hintViews.append(hintView)
				menuButtonsView.insertSubview(hintView, at: 0)
			}
			UIView.animate(
				withDuration: buttonHintAnimationDuration,
				delay: 0,
				options: .curveEaseInOut,
				animations: {
					invokedButton.frame.resize(y: Double(invokedButton.frame.minY) - self.hintPadding)
					invokedButton.indicator!.frame.resize(y: Double(invokedButton.indicator!.frame.minY) - self.hintPadding)
					hintViews[1].frame.resize(y: Double(hintViews[1].frame.minY) + self.hintPadding)
				},
				completion: nil
			)
			UIView.animate(
				withDuration: buttonHintAnimationDuration,
				delay: buttonHintAnimationDuration,
				options: .curveEaseInOut,
				animations: {
					invokedButton.resetPosition()
					invokedButton.indicator!.resetPosition()
					hintViews[0].frame = invokedButton.frame
					hintViews[1].frame = invokedButton.frame
				},
				completion: { b in
					self.shadowViewTapGestureRecognizer.isEnabled = true
					hintViews.forEach { $0.removeFromSuperview() }
					self.isHintShown = true
					seal.fulfill(Void())
				}
			)
		}
	}
	
	private func sendViewToBack() {
		guard let rootView = rootView else {
			assertionFailure("You must call `attach(to:)` before reordering subviews")
			return
		}
		rootView.insertSubview(self, belowSubview: shadowView)
	}
	
	private func sendViewToFront() {
		guard let rootView = self.rootView else {
			assertionFailure("You must call `attach(to:)` before reordering subviews")
			return
		}
		rootView.insertSubview(self, at: rootView.subviews.count)
	}
	
	private func startMoveButtonAnimation(button: CircleMenuButton, buttonPosition: CGPoint, indicatorPosition: CGPoint, duration: Double, delay: Double = 0, completion: ((Bool) -> Void)? = nil) {
		UIView.animate(
			withDuration: duration,
			delay: delay,
			options: .curveEaseInOut,
			animations: {
				button.position = buttonPosition
				button.indicator?.position = indicatorPosition
			},
			completion: completion
		)
	}
	
	private func setSwipeInteractions(enabled: Bool) -> Promise<Void> {
		return Promise { seal in
			mainButton.isUserInteractionEnabled = enabled
			panSwipe.isEnabled = enabled
			seal.fulfill(Void())
		}
	}
	
	private func setButtonInteractions(enabled: Bool) -> Promise<Void> {
		return Promise { seal in
			if enabled {
				menuButtons.forEach { $0.isUserInteractionEnabled = $0.positionIndex != 4 && $0.positionIndex != 0 }
			} else {
				menuButtons.forEach { $0.isUserInteractionEnabled = false }
			}
			seal.fulfill(Void())
		}
	}
	
	private func updateAppearance() {
		if #available(iOS 13.0, *) {
			// FIXME: Main button icon color not updating when switching between light and dark mode
			
			unfocusedBackgroundColor 	= .secondarySystemBackground
			unfocusedIconColor 			= .label
			
			focusedBackgroundColor 		= .systemBlue
			focusedIconColor 			= .white
			
			blackoutColor 				= UIColor.systemGray6.withAlphaComponent(0.64)
		} else {
			unfocusedBackgroundColor 	= UIColor.white
			unfocusedIconColor 			= UIColor(red:  51, green:  52, blue:  51)
			
			focusedBackgroundColor 		= UIColor(red:  60, green: 109, blue: 240)
			focusedIconColor 			= UIColor.white
			
			blackoutColor 				= UIColor(red: 246, green: 246, blue: 246).withAlphaComponent(0.64)
		}
	}
	
	override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let view = super.hitTest(point, with: event)
		
		switch view {
		case self, menuButtonsView:
			return nil
		default:
			return view
		}
	}
	
}
