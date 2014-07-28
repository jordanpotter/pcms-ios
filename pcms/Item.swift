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
	var allDimensions = Array<ItemDimensions>()
	
	init(serial: String) {
		self.serial = serial
	}
	
	func toJson() -> (NSData?, NSError?) {
		var dictionary = Dictionary<String, AnyObject>()
		dictionary["serial"] = self.serial
		if let id = self.id { dictionary["id"] = id }
		if let salesOrder = self.salesOrder { dictionary["sales_order_code"] = salesOrder }
		if let phase = self.phase { dictionary["phase"] = phase }
		if let shelf = self.shelf { dictionary["shelf"] = shelf }
		if let note = self.note { dictionary["note"] = note }
		
		var allDimensionsDictionaries = Array<Dictionary<String, Float>>()
		for dimensions in self.allDimensions {
			allDimensionsDictionaries.append(["length": dimensions.length, "width": dimensions.width])
		}
		dictionary["dimensions"] = allDimensionsDictionaries
		
		var error: NSError?
		let jsonedData = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions(0), error: &error)
		if error {
			return (nil, error)
		} else {
			return (jsonedData, nil)
		}
	}
	
	func saturateDataFromServer(completionHandler: ((NSError?) -> ())?) {
		NSLog("TODO: load item data here")
		self.id = 17
		self.salesOrder = "PT043R"
		self.phase = "NC"
		self.shelf = "D23"
		self.note = "This is an excellent film full of great potential"
		self.allDimensions.append(ItemDimensions(length: 17.0, width: 19.3))
		self.allDimensions.append(ItemDimensions(length: 13.1, width: 19.8))
		self.allDimensions.append(ItemDimensions(length: 13.9, width: 12.1))
		
		completionHandler?(nil)
	}
	
	func saveToServer(completionHandler: ((NSError?) -> Void)?) {
		NSLog("TODO: need to save item")
		completionHandler?(nil)
	}
}

func batchSaveItemsToServer(items: Array<Item>, completionHandler: ((NSError?) -> Void)?) {
	NSLog("TODO: need to batch save items")
	completionHandler?(nil)
}

func getAllowedPhasesForItems(items: Array<Item>) -> Array<String> {
	return ["some", "phases", "here"]
}

class ItemDimensions {
	var length: Float
	var width: Float
	var area: Float { return self.length * self.width }
	
	init(length: Float, width: Float) {
		self.length = length
		self.width = width
	}
	
	init(dimensions: ItemDimensions) {
		self.width = dimensions.width
		self.length = dimensions.length
	}
}

func deepCopyItemAllDimensions(allDimensions: Array<ItemDimensions>) -> Array<ItemDimensions> {
	var itemAllDimensionsCopy = Array<ItemDimensions>()
	for dimensions in allDimensions {
		itemAllDimensionsCopy.append(ItemDimensions(dimensions: dimensions))
	}
	return itemAllDimensionsCopy
}
