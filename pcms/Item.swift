//
//  Item.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

struct Item {
	var id: Int?
	var serial: String
	var salesOrder: String?
	var phase: String?
	var shelf: String?
	var note: String?
	var width: Float?
	var length: Float?
	var area: Float? {
		get {
			if !self.width || !self.length {
				return nil
			} else {
				return self.width! * self.length!
			}
		}
	}
	
	init(serial: String) {
		self.serial = serial
	}
	
	mutating func saturateData(completionHandler: ((NSError?) -> ())?) {
		NSLog("TODO: load item data here")
		self.id = 17
		self.salesOrder = "sales order"
		self.phase = "phase"
		self.shelf = "shelf 1"
		self.width = 17.0
		self.length = 13.9
		self.note = "some note here"
		
		completionHandler?(nil)
	}
}
