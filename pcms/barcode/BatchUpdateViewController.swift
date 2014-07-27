//
//  BatchUpdateViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/26/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class BatchUpdateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	var currentItems: Array<Item>?
	var allowedPhases = Array<String>()
	var saveButton: UIBarButtonItem?
	
	@IBOutlet weak var shelfTextField: UITextField!
	@IBOutlet weak var phasePicker: UIPickerView!
	
	var shelf: String? {
		let shelfValue = self.shelfTextField.text
		if shelfValue.isEmpty {
			return nil
		} else {
			return shelfValue
		}
	}
	
	var phase: String? {
		return self.allowedPhases[self.phasePicker.selectedRowInComponent(0)]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let currentItems = self.currentItems {
			self.allowedPhases = getAllowedPhasesForItems(currentItems)
		}
		
		self.phasePicker.delegate = self
		self.phasePicker.dataSource = self
		
		self.saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "save")
		self.navigationItem.rightBarButtonItem = self.saveButton
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
		return self.allowedPhases.count
	}
	
	func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
		return self.allowedPhases[row]
	}
	
	func save() {
		if let currentItems = self.currentItems {
			for item in currentItems {
				if let shelf = self.shelf {
					NSLog("shelf: %@", shelf)
					item.shelf = shelf
				}
				
				if let phase = self.phase {
					NSLog("phase: %@", phase)
					item.phase = phase
				}
			}
		}
		
		self.navigationController.popViewControllerAnimated(true)
	}
}
