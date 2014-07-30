//
//  ScannedItemTableViewCell.swift
//  pcms
//
//  Created by Jordan Potter on 7/25/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class ScannedItemTableViewCell: UITableViewCell {
	@IBOutlet weak var serialLabel: UILabel!
	@IBOutlet weak var phaseLabel: UILabel!
	@IBOutlet weak var shelfLabel: UILabel!
	
	var serial: String? {
		get {
			return self.serialLabel.text
		}
		set {
			self.serialLabel.text = newValue
		}
	}
	
	var phase: String? {
		get {
			return self.phaseLabel.text
		}
		set {
			self.phaseLabel.text = newValue
		}
	}
	
	var shelf: String? {
		get {
			return self.shelfLabel.text
		}
		set {
			self.shelfLabel.text = newValue
		}
	}
}