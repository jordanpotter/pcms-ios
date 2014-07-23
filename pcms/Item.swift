//
//  Item.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

struct Item {
	var id: String
	var shelf: String?
	var width: Float?
	var height: Float?
	var area: Float? {
		get {
			if !self.width || !self.height {
				return nil
			} else {
				return self.width! * self.height!
			}
		}
	}
	
	init(id: String) {
		self.id = id
	}
	
	mutating func saturateData(completionHandler: (NSError?) -> ()) {
		NSLog("TODO: load item data here")
		self.width = 17.0
		self.height = 13.9
		self.shelf = "shelf 1"
		
		completionHandler(nil)
	}
}
