//
//  DimensionsTableViewCell.swift
//  pcms
//
//  Created by Jordan Potter on 7/26/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class DimensionsTableViewCell: UITableViewCell {
	@IBOutlet weak var lengthLabel: UILabel!
	@IBOutlet weak var widthLabel: UILabel!
	@IBOutlet weak var areaLabel: UILabel!

	var length: Float {
	get {
		return self.lengthLabel.text.bridgeToObjectiveC().floatValue
	}
	set {
		self.lengthLabel.text = newValue.bridgeToObjectiveC().stringValue
	}
	}
	
	var width: Float {
	get {
		return self.widthLabel.text.bridgeToObjectiveC().floatValue
	}
	set {
		self.widthLabel.text = newValue.bridgeToObjectiveC().stringValue
	}
	}
	
	var area: Float {
	get {
		return self.areaLabel.text.bridgeToObjectiveC().floatValue
	}
	set {
		self.areaLabel.text = newValue.bridgeToObjectiveC().stringValue
	}
	}
}