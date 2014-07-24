//
//  ItemDetailsViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class ItemDetailsViewController: UIViewController {
	var item: Item?
	@IBOutlet weak var salesOrderButton: UIButton!
	@IBOutlet weak var phaseButton: UIButton!
	@IBOutlet weak var shelfTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = self.item?.serial
		self.setupUI()
	}
	
	func setupUI() {
		self.setTitleForAllButtonStates(self.salesOrderButton, title: self.item?.salesOrder)
		self.setTitleForAllButtonStates(self.phaseButton, title: self.item?.phase)
	}
	
	func setTitleForAllButtonStates(button: UIButton!, title:NSString?) {
		button.setTitle(title, forState: .Normal)
		button.setTitle(title, forState: .Highlighted)
		button.setTitle(title, forState: .Disabled)
		button.setTitle(title, forState: .Selected)
	}
	
	@IBAction func clickedBackground(sender: UITapGestureRecognizer) {
		self.resignAllResponders()
	}
	
	func resignAllResponders() {
		self.shelfTextField.resignFirstResponder()
	}
	
	@IBAction func salesOrderButtonClicked() {
		NSLog("sales order button clicked")
	}
	
	@IBAction func phaseButtonClicked() {
		NSLog("phase button clicked")
	}
}
