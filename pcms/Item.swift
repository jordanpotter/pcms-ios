//
//  Item.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

let MIN_ORDER_FILL_COUNT = 0
let MAX_ORDER_FILL_COUNT = 10

class Item {
	var id: Int
	var serial: String?
	var salesOrder: String?
	var orderFillCount: Int?
	var phase: String?
	var shelf: String?
	var note: String?
	var allDimensions = Array<ItemDimensions>()
	
	init(json: NSDictionary) {
		self.id = json["id"] as Int
		self.serial = json["serial"] as? String
		self.salesOrder = json["sales_order_code"] as? String
		self.orderFillCount = json["order_fill_count"] as? Int
		self.phase = json["phase"] as? String
		self.shelf = json["shelf"] as? String
		self.note = json["note"] as? String
		
		if let jsonAllDimensions = json["dimensions"] as? Array<NSDictionary> {
			for jsonDimensions in jsonAllDimensions {
				self.allDimensions.append(ItemDimensions(json: jsonDimensions))
			}
		}
	}
	
	func toJson() -> (data: NSData?, error: NSError?) {
		var dictionary = Dictionary<String, AnyObject>()
		dictionary["id"] = id
//		dictionary["serial"] = self.serial?
		if let serial = self.serial { dictionary["serial"] = serial}
		if let salesOrder = self.salesOrder { dictionary["sales_order_code"] = salesOrder }
		if let orderFillCount = self.orderFillCount { dictionary["order_fill_count"] = orderFillCount }
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
	
	class func getAllowedPhasesForItems(items: Array<Item>) -> Array<String> {
		return ["some", "phases", "here"]
	}
}

class ItemDimensions {
	var length: Float = 0.0
	var width: Float = 0.0
	var area: Float { return self.length * self.width }
	
	init(length: Float, width: Float) {
		self.length = length
		self.width = width
	}
	
	init(dimensions: ItemDimensions) {
		self.width = dimensions.width
		self.length = dimensions.length
	}
	
	init(json: NSDictionary) {
		self.length = json["length"].floatValue
		self.width = json["width"].floatValue
	}
	
	class func deepCopyAllDimensions(allDimensions: Array<ItemDimensions>) -> Array<ItemDimensions> {
		var itemAllDimensionsCopy = Array<ItemDimensions>()
		for dimensions in allDimensions {
			itemAllDimensionsCopy.append(ItemDimensions(dimensions: dimensions))
		}
		return itemAllDimensionsCopy
	}
}
