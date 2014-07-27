//
//  DimensionsDetailsViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/26/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class DimensionsDetailsViewController: UIViewController, UITextFieldDelegate {
	var dimensions: ItemDimensions?
	
	@IBOutlet weak var lengthTextField: UITextField!
	@IBOutlet weak var widthTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.lengthTextField.delegate = self
		self.widthTextField.delegate = self
		
		self.updateUI()
	}
	
	func updateUI() {
		self.lengthTextField.text = self.dimensions?.length.bridgeToObjectiveC().stringValue
		self.widthTextField.text = self.dimensions?.width.bridgeToObjectiveC().stringValue
	}
	
	@IBAction func clickedBackground(sender: UITapGestureRecognizer) {
		self.resignAllResponders()
	}
	
	func resignAllResponders() {
		self.lengthTextField.resignFirstResponder()
		self.widthTextField.resignFirstResponder()
	}
	
	func textFieldDidEndEditing(textField: UITextField!) {
		if let dimensions = self.dimensions {
			if textField == self.lengthTextField {
				dimensions.length = self.lengthTextField.text.bridgeToObjectiveC().floatValue
			} else if textField == self.widthTextField {
				dimensions.width = self.widthTextField.text.bridgeToObjectiveC().floatValue
			}
		}
	}
}
