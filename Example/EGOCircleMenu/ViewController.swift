//
//  ViewController.swift
//  CircleMenu
//
//  Created by Pavel Chehov on 08/11/2018.
//

import UIKit
import EGOCircleMenu

class ViewController: UIViewController {
	
	var icons = ["icImage", "icPanorama", "icVideo", "icPhoto","icTimelapse","icMacro", "icPortrait", "icSeries", "icTimer", "icSixteenToNine", "icOneToOne", "icHDR"]
	let submenuIds = [2,3]
	let showItemSegueId = "showItem"
	var selectedItemId: Int?
	
	@IBOutlet weak var idLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			view.backgroundColor = .systemBackground
		}
		
		let circleMenu = CircleMenu()
		circleMenu.attach(to: self)
		circleMenu.delegate = self
		
		// Here you can customize needed properties
		circleMenu.circleMenuItems = createCircleMenuItems(count: 9)

//		circleMenu.focusedIconColor 		= .red
//		circleMenu.unfocusedIconColor 		= .green
//		circleMenu.focusedBackgroundColor 	= .black
//		circleMenu.unfocusedBackgroundColor = .yellow
//		circleMenu.blackoutColor 			= UIColor.black.withAlphaComponent(0.5)
//
//		circleMenu.tappingShadowViewCloses = .none // In [.none, .submenuOnly, .menuOnly, .all, .allAtTheSameTime]
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.isNavigationBarHidden = true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier == showItemSegueId, let selectedItemId = selectedItemId else { return }
		
		let viewController = segue.destination as! MenuItemViewController
		viewController.imageSource = icons[selectedItemId]
	}
	
	private func createCircleMenuItems(count: Int) -> [CircleMenuItemModel] {
		var menuModels = [CircleMenuItemModel]()
		for i in 0..<count {
			let menuModel = CircleMenuItemModel(id: i, imageSource: UIImage(named: icons[i]))
			if submenuIds.contains(i) {
				for j in 9..<12 {
					let submenuModel = CircleMenuItemModel(id: j, imageSource: UIImage(named: icons[j]))
					menuModel.children.append(submenuModel)
				}
			}
			menuModels.append(menuModel)
		}
		return menuModels
	}
	
}

// MARK: - CircleMenuDelegate

extension ViewController: CircleMenuDelegate {

	func menuItemSelected(id: Int) {
		idLabel.text = "id: \(id)"
		selectedItemId = id
		
		guard id != 100 else {
			// Selected main menu button
			return
		}
		
		guard !submenuIds.contains(id) else {
			// Selected submenu item
			return
		}
		
		performSegue(withIdentifier: showItemSegueId, sender: self)
	}
	
}
