//
//  CircleMenuItemModel.swift
//  CircleMenu
//
//  Created by Pavel Chehov on 08/11/2018.
//

import UIKit

public class CircleMenuItemModel {
	
	public var id: Int?
	public var imageSource: UIImage?
	public var children = [CircleMenuItemModel]()
	public var hasChildren: Bool { !children.isEmpty }
	
	public init(id: Int?, imageSource: UIImage?, children: [CircleMenuItemModel]? = nil) {
		self.id = id
		self.imageSource = imageSource?.withRenderingMode(.alwaysTemplate)
		self.children = children ?? []
	}
	
}
