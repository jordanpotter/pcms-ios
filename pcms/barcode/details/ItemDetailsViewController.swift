//
//  ItemDetailsViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

enum ItemDetailsState {
	case Default
	case SettingSalesOrder
	case SettingOrderFillCount
}

class ItemDetailsViewController: UIViewController, UITableViewDataSource, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
	var state: ItemDetailsState = .Default
	var item: Item?
	var allowedSalesOrders = Array<String>()
	var saveButton: UIBarButtonItem?
	var setSalesOrderButton: UIBarButtonItem?
	var cancelSetSalesOrderButton: UIBarButtonItem?
	var setOrderFillCountButton: UIBarButtonItem?
	var cancelSetOrderFillCountButton: UIBarButtonItem?
	var noteTextViewOriginalBottom = CGFloat(0.0)
	
	var newSalesOrder: String?
	var newOrderFillCount: Int?
	var newNote: String?
	var newAllDimensions: Array<ItemDimensions>?
	
	@IBOutlet weak var pickerOverlay: UIView!
	@IBOutlet weak var salesOrderButton: UIButton!
	@IBOutlet weak var salesOrderPicker: UIPickerView!
	@IBOutlet weak var orderFillCountPicker: UIPickerView!
	@IBOutlet weak var orderFillCountButton: UIButton!
	@IBOutlet weak var dimensionsTableView: UITableView!
	@IBOutlet weak var noteTextView: UITextView!
	
	@IBOutlet weak var dimensionsTableHeight: NSLayoutConstraint!
	@IBOutlet weak var noteTextViewBottom: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = self.item?.serial
		
		self.newSalesOrder = self.item?.salesOrder
		self.newOrderFillCount = self.item?.orderFillCount
		self.newNote = self.item?.note
		
		if let item = self.item {
			self.newAllDimensions = ItemDimensions.deepCopyAllDimensions(item.allDimensions)
		}
		
		self.saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveItem")
		self.setSalesOrderButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "setSalesOrder")
		self.cancelSetSalesOrderButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSetSalesOrder")
		self.setOrderFillCountButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "setOrderFillCount")
		self.cancelSetOrderFillCountButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSetOrderFillCount")
		
		self.salesOrderPicker.delegate = self
		self.salesOrderPicker.dataSource = self
		self.orderFillCountPicker.delegate = self
		self.orderFillCountPicker.dataSource = self
		self.dimensionsTableView.dataSource = self
		self.noteTextView.delegate = self
		
		self.syncUI()
		self.retrieveSalesOrders()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.dimensionsTableView.reloadData()
		
		let numDimensions = self.item!.allDimensions.count
		if let cell = self.dimensionsTableView.dequeueReusableCellWithIdentifier("item dimensions cell") as? DimensionsTableViewCell {
			let dimensionsTableCellHeight = cell.frame.height
			self.dimensionsTableHeight.constant = max(dimensionsTableCellHeight, min(self.dimensionsTableHeight.constant, dimensionsTableCellHeight * CGFloat(numDimensions)))
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:keyboardAppeared)
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:keyboardDisappeared)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.noteTextViewOriginalBottom = self.noteTextViewBottom.constant
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardDidShowNotification, object:nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "show dimensions details" {
			let indexPath: NSIndexPath = self.dimensionsTableView.indexPathForSelectedRow()
			let selectedDimensions = self.newAllDimensions?[indexPath.row]
			
			let dimensionsDetailsViewController = segue.destinationViewController as DimensionsDetailsViewController
			dimensionsDetailsViewController.dimensions = selectedDimensions
		}
	}
	
	func syncUI() {
		self.setTitleForAllButtonStates(self.salesOrderButton, title: self.newSalesOrder)
		self.setTitleForAllButtonStates(self.orderFillCountButton, title: String(self.newOrderFillCount!))
		self.noteTextView.text = self.newNote
		
		switch self.state {
		case .Default:
			self.title = self.item?.serial
			self.salesOrderPicker.hidden = true
			self.orderFillCountPicker.hidden =  true
			self.pickerOverlay.hidden = true
			self.navigationItem.leftBarButtonItem = nil
			self.navigationItem.rightBarButtonItem = self.saveButton
		case .SettingSalesOrder:
			self.title = "Sales Order"
			self.salesOrderPicker.hidden = false
			self.orderFillCountPicker.hidden =  true
			self.pickerOverlay.hidden = false
			self.navigationItem.leftBarButtonItem = self.cancelSetSalesOrderButton
			self.navigationItem.rightBarButtonItem = self.setSalesOrderButton
		case .SettingOrderFillCount:
			self.title = "Order Fill Count"
			self.salesOrderPicker.hidden = true
			self.orderFillCountPicker.hidden =  false
			self.pickerOverlay.hidden = false
			self.navigationItem.leftBarButtonItem = self.cancelSetOrderFillCountButton
			self.navigationItem.rightBarButtonItem = self.setOrderFillCountButton
		}
	}
	
	func setTitleForAllButtonStates(button: UIButton!, title:NSString?) {
		button.setTitle(title, forState: .Normal)
		button.setTitle(title, forState: .Highlighted)
		button.setTitle(title, forState: .Disabled)
		button.setTitle(title, forState: .Selected)
	}
	
	func retrieveSalesOrders() {
		Api.retrieveSalesOrders() { (retrievedSalesOrders: Array<String>?, error: NSError?) in
			NSOperationQueue.mainQueue().addOperationWithBlock() {
				if error {
					let alertString = error!.localizedDescription
					let alert = UIAlertView(title: "Server Error", message: alertString, delegate: nil, cancelButtonTitle: "Ok")
					alert.show()
				} else if let salesOrders = retrievedSalesOrders {
					self.allowedSalesOrders = salesOrders
					self.salesOrderPicker.reloadAllComponents()
				}
			}
		}
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
			self.noteTextViewBottom.constant = self.noteTextViewOriginalBottom + keyboardFrame.size.height
		}
	}
	
	func keyboardDisappeared(notification: NSNotification!) {
		self.noteTextViewBottom.constant = self.noteTextViewOriginalBottom
	}
	
	func textViewDidEndEditing(textView: UITextView!) {
		self.newNote = self.noteTextView.text
	}
	
	func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		if let newAllDimensions = self.newAllDimensions {
			return newAllDimensions.count
		} else {
			return 0
		}
	}
	
	func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		if let cell = tableView?.dequeueReusableCellWithIdentifier("item dimensions cell") as? DimensionsTableViewCell {
			if let dimensions = self.newAllDimensions?[indexPath!.row] {
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
		self.state = .SettingSalesOrder
		self.syncUI()
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
		self.syncUI()
		self.state = .Default
		self.syncUI()
	}
	
	func cancelSetSalesOrder() {
		self.state = .Default
		self.syncUI()
	}
	
	@IBAction func orderFillCountButtonClicked() {
		self.resignAllResponders()
		self.selectOrderFillCountInPicker(self.newOrderFillCount)
		self.state = .SettingOrderFillCount
		self.syncUI()
	}
	
	func selectOrderFillCountInPicker(orderFillCount: Int?) {
		if orderFillCount && orderFillCount! >= MIN_ORDER_FILL_COUNT && orderFillCount! <= MAX_ORDER_FILL_COUNT {
			self.orderFillCountPicker.selectRow(orderFillCount! + MIN_ORDER_FILL_COUNT, inComponent: 0, animated: false)
		}
	}
	
	func setOrderFillCount() {
		self.newOrderFillCount = self.orderFillCountPicker.selectedRowInComponent(0) + MIN_ORDER_FILL_COUNT
		self.syncUI()
		self.state = .Default
		self.syncUI()
	}
	
	func cancelSetOrderFillCount() {
		self.state = .Default
		self.syncUI()
	}

	func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
		switch pickerView {
		case self.salesOrderPicker: return self.allowedSalesOrders.count
		case self.orderFillCountPicker: return MAX_ORDER_FILL_COUNT - MIN_ORDER_FILL_COUNT + 1
		default: return 0
		}
	}
	
	func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
		switch pickerView {
		case self.salesOrderPicker: return self.allowedSalesOrders[row]
		case self.orderFillCountPicker: return String(row + MIN_ORDER_FILL_COUNT)
		default: return ""
		}
	}
	
	func saveItem() {
		// This forces a sync with the note text view if the
		// user clicks save while editng the note, since
		// the "end editing" event won't fire in time
		self.textViewDidEndEditing(self.noteTextView)
		
		if let item = self.item {
			item.salesOrder = self.newSalesOrder
			item.note = self.newNote
			item.allDimensions = self.newAllDimensions!
			
			Api.saveItem(item) { (error: NSError?) in
				NSOperationQueue.mainQueue().addOperationWithBlock() {
					if error {
						let alertString = error!.localizedDescription
						let alert = UIAlertView(title: "Server Error", message: alertString, delegate: nil, cancelButtonTitle: "Ok")
						alert.show()
					} else {
						self.navigationController.popViewControllerAnimated(true)
					}
				}
			}
		}
	}
}
