//
//  ItemDetailsViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class ItemDetailsViewController: UIViewController, UITableViewDataSource, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
	var item: Item?
	var allowedSalesOrders = Array<String>()
	var saveButton: UIBarButtonItem?
	var setSalesOrderButton: UIBarButtonItem?
	var cancelSetSalesOrderButton: UIBarButtonItem?
	var noteTextViewOriginalBottom = 0.0
	
	var newSalesOrder: String?
	var newNote: String?
	
	@IBOutlet weak var salesOrderButton: UIButton!
	@IBOutlet weak var salesOrderPicker: UIPickerView!
	@IBOutlet weak var salesOrderPickerOverlay: UIView!
	@IBOutlet weak var dimensionsTableView: UITableView!
	@IBOutlet weak var noteTextView: UITextView!
	@IBOutlet weak var noteTextViewBottom: NSLayoutConstraint!
	
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
		self.dimensionsTableView.dataSource = self
		self.noteTextView.delegate = self
		
		self.updateUI()
		
		NSLog("Need to pull possible sales orders here")
		self.allowedSalesOrders.append("PD055R")
		self.allowedSalesOrders.append("PT043R")
		self.allowedSalesOrders.append("PD985Q")
		self.allowedSalesOrders.append("PD341L")
		self.allowedSalesOrders.append("PT721M")
		self.allowedSalesOrders.append("PD212R")
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:keyboardAppeared)
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:keyboardDisappeared)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.noteTextViewOriginalBottom = Double(self.noteTextViewBottom.constant)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardDidShowNotification, object:nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		NSLog("~~ %@", segue.identifier)
		if segue.identifier == "show dimensions details" {
			let indexPath: NSIndexPath = self.dimensionsTableView.indexPathForSelectedRow()
			let selectedDimensions = self.item?.dimensions[indexPath.row]
			
			let dimensionsDetailsViewController = segue.destinationViewController as DimensionsDetailsViewController
			dimensionsDetailsViewController.dimensions = selectedDimensions
		}
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
	
	func keyboardAppeared(notification: NSNotification!) {
		if let rectValue = notification.userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
			let keyboardFrame:CGRect = rectValue.CGRectValue()
			self.noteTextViewBottom.constant = CGFloat(self.noteTextViewOriginalBottom) + keyboardFrame.size.height
		}
	}
	
	func keyboardDisappeared(notification: NSNotification!) {
		self.noteTextViewBottom.constant = CGFloat(self.noteTextViewOriginalBottom)
	}
	
	func textViewDidEndEditing(textView: UITextView!) {
		self.newNote = self.noteTextView.text
	}
	
	func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		if self.item? {
			return self.item!.dimensions.count
		} else {
			return 0
		}
	}
	
	func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		if let cell = tableView?.dequeueReusableCellWithIdentifier("item dimensions cell") as? DimensionsTableViewCell {
			if let dimensions = self.item?.dimensions[indexPath!.row] {
				cell.length = dimensions.length
				cell.width = dimensions.width
				cell.area = dimensions.area
			}
			return cell
		} else {
			return nil
		}
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
	
	func saveItem() {
		NSLog("Need to save item")
	}
}
