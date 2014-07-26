//
//  ItemDetailsViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class ItemDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
	var item: Item?
	var allowedSalesOrders = Array<String>()
	var saveButton: UIBarButtonItem?
	var setSalesOrderButton: UIBarButtonItem?
	var cancelSetSalesOrderButton: UIBarButtonItem?
	
	var newSalesOrder: String?
	var newNote: String?
	
	@IBOutlet weak var salesOrderButton: UIButton!
	@IBOutlet weak var salesOrderPicker: UIPickerView!
	@IBOutlet weak var salesOrderPickerOverlay: UIView!
	@IBOutlet weak var noteTextView: UITextView!
	
	var settingSalesOrder: Bool {
		get {
			return !self.salesOrderPicker.hidden
		}
		set {
			if newValue {
				self.salesOrderPicker.hidden = false
				self.salesOrderPickerOverlay.hidden = false
				self.navigationItem.leftBarButtonItem = self.cancelSetSalesOrderButton
				self.navigationItem.rightBarButtonItem = self.setSalesOrderButton
			} else {
				self.salesOrderPicker.hidden = true
				self.salesOrderPickerOverlay.hidden = true
				self.navigationItem.leftBarButtonItem = nil
				self.navigationItem.rightBarButtonItem = self.saveButton
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = self.item?.serial
		
		self.newSalesOrder = self.item?.salesOrder
		self.newNote = self.item?.note
		self.settingSalesOrder = false
		
		self.saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveItem")
		self.setSalesOrderButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "setSalesOrder")
		self.cancelSetSalesOrderButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSetSalesOrder")
		
		self.salesOrderPicker.delegate = self
		self.salesOrderPicker.dataSource = self
		
		self.updateUI()
		
		NSLog("Need to pull possible sales orders here")
		self.allowedSalesOrders.append("PD055R")
		self.allowedSalesOrders.append("PT043R")
		self.allowedSalesOrders.append("PD985Q")
		self.allowedSalesOrders.append("PD341L")
		self.allowedSalesOrders.append("PT721M")
		self.allowedSalesOrders.append("PD212R")
	}
	
	func updateUI() {
		self.setTitleForAllButtonStates(self.salesOrderButton, title: self.newSalesOrder)
		self.noteTextView.text = self.newNote
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
		self.noteTextView.resignFirstResponder()
	}
	
	@IBAction func salesOrderButtonClicked() {
		self.resignAllResponders()
		self.selectSalesOrderInPicker(self.newSalesOrder)
		self.settingSalesOrder = true
	}
	
	func selectSalesOrderInPicker(salesOrder: String?) {
		for (index, allowedSalesOrder) in enumerate(self.allowedSalesOrders) {
			if salesOrder == allowedSalesOrder {
				self.salesOrderPicker.selectRow(index, inComponent: 0, animated: false)
			}
		}
	}
	
	func saveItem() {
		NSLog("Need to save item")
	}
	
	func setSalesOrder() {
		self.newSalesOrder = self.allowedSalesOrders[self.salesOrderPicker.selectedRowInComponent(0)]
		self.updateUI()
		self.settingSalesOrder = false
	}
	
	func cancelSetSalesOrder() {
		self.settingSalesOrder = false
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
		return self.allowedSalesOrders.count
	}
	
	func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
		return self.allowedSalesOrders[row]
	}
}
