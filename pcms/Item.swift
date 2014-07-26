//
//  Item.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

class Item {
	var id: Int?
	var serial: String
	var salesOrder: String?
	var phase: String?
	var shelf: String?
	var note: String?
	var dimensions = Array<ItemDimensions>()
	
	init(serial: String) {
		self.serial = serial
	}
	
	func saturateData(completionHandler: ((NSError?) -> ())?) {
		NSLog("TODO: load item data here")
		self.id = 17
		self.salesOrder = "PT043R"
		self.phase = "NC"
		self.shelf = "D23"
		self.note = "This is an excellent film full of great potential"
		self.dimensions.append(ItemDimensions(width: 17.0, length: 19.3))
		self.dimensions.append(ItemDimensions(width: 13.1, length: 19.8))
		
		completionHandler?(nil)
	}
}

struct ItemDimensions {
	var width: Float
	var length: Float
	var area: Float { return self.width * self.length }
}
