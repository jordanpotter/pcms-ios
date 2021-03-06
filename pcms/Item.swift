//
//  Item.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

let MIN_ORDER_FILL_COUNT = 1
let MAX_ORDER_FILL_COUNT = 50

class Item {
	var id: Int
	var serial: String
	var salesOrder: ItemSalesOrder?
	var orderFillCount: Int
	var phase: String
	var allowedPhases: Array<String>
	var shelf: String?
	var note: String?
	var allDimensions = Array<ItemDimensions>()
	
	init(json: NSDictionary) {
		self.id = json["id"] as Int
		self.serial = json["serial"] as String
		self.orderFillCount = json["order_fill_count"] as Int
		self.phase = json["phase"] as String
		self.allowedPhases = json["allowed_destinations"] as Array<String>
		self.shelf = json["shelf"] as? String
		self.note = json["note"] as? String
		
		if let jsonSalesOrder = json["sales_order"] as? NSDictionary {
			self.salesOrder = ItemSalesOrder(json: jsonSalesOrder)
		}
		
		if let jsonAllDimensions = json["dimensions"] as? Array<NSDictionary> {
			for jsonDimensions in jsonAllDimensions {
				self.allDimensions.append(ItemDimensions(json: jsonDimensions))
			}
		}
	}
	
	func toDictionary() -> Dictionary<String, AnyObject> {
		var dictionary = Dictionary<String, AnyObject>()
		dictionary["id"] = self.id
		dictionary["serial"] = self.serial
		if let salesOrder = self.salesOrder { dictionary["sales_order_id"] = salesOrder.id }
		dictionary["order_fill_count"] = self.orderFillCount
		dictionary["destination"] = self.phase
		if let shelf = self.shelf { dictionary["shelf"] = shelf }
		if let note = self.note { dictionary["note"] = note }
		
		var allDimensionsDictionaries = Array<Dictionary<String, AnyObject>>()
		for dimensions in self.allDimensions {
			allDimensionsDictionaries.append(dimensions.toDictionary())
		}
		dictionary["dimensions_attributes"] = allDimensionsDictionaries
		
		return dictionary
	}
	
	func toJson() -> (data: NSData?, error: NSError?) {
		let dictionary = self.toDictionary()

		var error: NSError?
		let jsonedData = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions(0), error: &error)
		if error {
			return (nil, error)
		} else {
			return (jsonedData, nil)
		}
	}
	
	class func getAllowedPhasesForItems(items: Array<Item>) -> Array<String> {
		var allowedPhases = Array<String>()
		
		for (index, item) in enumerate(items) {
			if index == 0 {
				allowedPhases = item.allowedPhases
			} else {
				allowedPhases = allowedPhases.filter() { (phase: String) -> Bool in
					for allowedItemPhase in item.allowedPhases {
						if phase == allowedItemPhase {
							return true
						}
					}
					return false
				}
			}
		}
		
		return allowedPhases
	}
}

class ItemSalesOrder {
	let id: Int
	let code: String
	
	init(id: Int, code: String) {
		self.id = id
		self.code = code
	}
	
	init(json: NSDictionary) {
		self.id = json["id"] as Int
		self.code = json["code"] as String
	}
	
	func toDictionary() -> Dictionary<String, AnyObject> {
		var dictionary = Dictionary<String, AnyObject>()
		dictionary["id"] = self.id
		dictionary["code"] = self.code
		return dictionary
	}
	
	func deepCopy() -> ItemSalesOrder {
		return ItemSalesOrder(id: self.id, code: self.code)
	}
}

class ItemDimensions {
	let id: Int
	var length: Float = 0.0
	var width: Float = 0.0
	
	init(id: Int, length: Float, width: Float) {
		self.id = id
		self.length = length
		self.width = width
	}
	
	init(json: NSDictionary) {
		self.id = json["id"] as Int
		self.length = json["length"] as Float
		self.width = json["width"] as Float
	}
	
	func toDictionary() -> Dictionary<String, AnyObject> {
		var dictionary = Dictionary<String, AnyObject>()
		dictionary["id"] = self.id
		dictionary["length"] = self.length
		dictionary["width"] = self.width
		return dictionary
	}
	
	func deepCopy() -> ItemDimensions {
		return ItemDimensions(id: self.id, length: self.length, width: self.width)
	}
	
	class func deepCopyAllDimensions(allDimensions: Array<ItemDimensions>) -> Array<ItemDimensions> {
		var itemAllDimensionsCopy = Array<ItemDimensions>()
		for dimensions in allDimensions {
			itemAllDimensionsCopy.append(dimensions.deepCopy())
		}
		return itemAllDimensionsCopy
	}
}
