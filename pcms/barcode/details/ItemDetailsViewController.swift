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
}

class ItemDetailsViewController: UIViewController, UITableViewDataSource, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
	var state: ItemDetailsState = .Default
	var item: Item?
	var allowedSalesOrders = Array<ItemSalesOrder>()
	var saveButton: UIBarButtonItem?
	var setSalesOrderButton: UIBarButtonItem?
	var cancelSetSalesOrderButton: UIBarButtonItem?
	var noteTextViewOriginalBottom = CGFloat(0.0)
	
	var newSalesOrder: ItemSalesOrder?
	var newOrderFillCount: Int?
	var newNote: String?
	var newAllDimensions: Array<ItemDimensions>?
	
	@IBOutlet weak var salesOrderPickerOverlay: UIView!
	@IBOutlet weak var salesOrderButton: UIButton!
	@IBOutlet weak var salesOrderPicker: UIPickerView!
	@IBOutlet weak var dimensionsTableView: UITableView!
	@IBOutlet weak var noteTextView: UITextView!
	
	@IBOutlet weak var dimensionsTableHeight: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = self.item?.serial
		
		self.newSalesOrder = self.item?.salesOrder?.deepCopy()
		self.newOrderFillCount = self.item?.orderFillCount
		self.newNote = self.item?.note
		
		if let item = self.item {
			self.newAllDimensions = ItemDimensions.deepCopyAllDimensions(item.allDimensions)
		}
		
		self.saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveItem")
		self.setSalesOrderButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "setSalesOrder")
		self.cancelSetSalesOrderButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSetSalesOrder")
		
		self.salesOrderPicker.delegate = self
		self.salesOrderPicker.dataSource = self
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
		let salesOrderButtonTitle = self.generateSalesOrderButtonTitle(self.newSalesOrder?.code, orderFillCount: self.newOrderFillCount)
		self.setTitleForAllButtonStates(self.salesOrderButton, title: salesOrderButtonTitle)
		self.noteTextView.text = self.newNote
		
		switch self.state {
		case .Default:
			self.title = self.item?.serial
			self.salesOrderPicker.hidden = true
			self.salesOrderPickerOverlay.hidden = true
			self.navigationItem.leftBarButtonItem = nil
			self.navigationItem.rightBarButtonItem = self.saveButton
		case .SettingSalesOrder:
			self.title = "Sales Order"
			self.salesOrderPicker.hidden = false
			self.salesOrderPickerOverlay.hidden = false
			self.navigationItem.leftBarButtonItem = self.cancelSetSalesOrderButton
			self.navigationItem.rightBarButtonItem = self.setSalesOrderButton
		}
	}
	
	func generateSalesOrderButtonTitle(salesOrder: String?, orderFillCount: Int?) -> String? {
		var buttonTitle = ""
		if salesOrder {
			buttonTitle += salesOrder!
		} else {
			buttonTitle += "no sales order"
		}
		
		if orderFillCount {
			buttonTitle += " (\(orderFillCount!))"
		}
		
		return buttonTitle
	}
	
	func setTitleForAllButtonStates(button: UIButton!, title:NSString?) {
		button.setTitle(title, forState: .Normal)
		button.setTitle(title, forState: .Highlighted)
		button.setTitle(title, forState: .Disabled)
		button.setTitle(title, forState: .Selected)
	}
	
	func retrieveSalesOrders() {
		Api.retrieveSalesOrders() { (retrievedSalesOrders: Array<ItemSalesOrder>?, error: NSError?) in
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
			}
			return cell
		} else {
			return nil
		}
	}
	
	@IBAction func salesOrderButtonClicked() {
		self.resignAllResponders()
		self.selectSalesOrderInPicker(self.newSalesOrder, orderFillCount: self.newOrderFillCount)
		self.state = .SettingSalesOrder
		self.syncUI()
	}
	
	func selectSalesOrderInPicker(salesOrder: ItemSalesOrder?, orderFillCount: Int?) {
		for (index, allowedSalesOrder) in enumerate(self.allowedSalesOrders) {
			if salesOrder?.code == allowedSalesOrder.code {
				self.salesOrderPicker.selectRow(index, inComponent: 0, animated: false)
			}
		}

		if orderFillCount && orderFillCount! >= MIN_ORDER_FILL_COUNT && orderFillCount! <= MAX_ORDER_FILL_COUNT {
			self.salesOrderPicker.selectRow(orderFillCount! + MIN_ORDER_FILL_COUNT, inComponent: 1, animated: false)
		}
	}
	
	func setSalesOrder() {
		self.newSalesOrder = self.allowedSalesOrders[self.salesOrderPicker.selectedRowInComponent(0)]
		self.newOrderFillCount = self.salesOrderPicker.selectedRowInComponent(1) + MIN_ORDER_FILL_COUNT
		self.syncUI()
		self.state = .Default
		self.syncUI()
	}
	
	func cancelSetSalesOrder() {
		self.state = .Default
		self.syncUI()
	}
	
	func cancelSetOrderFillCount() {
		self.state = .Default
		self.syncUI()
	}

	func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
		return 2
	}
	
	func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == self.salesOrderPicker {
			if component == 0 {
				return self.allowedSalesOrders.count
			} else if component == 1 {
				return MAX_ORDER_FILL_COUNT - MIN_ORDER_FILL_COUNT + 1
			} else {
				return 0
			}
		} else {
			return 0
		}
	}
	
	func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
		if pickerView == self.salesOrderPicker {
			if component == 0 {
				return self.allowedSalesOrders[row].code
			} else if component == 1 {
				return String(row + MIN_ORDER_FILL_COUNT)
			} else {
				return ""
			}
		} else {
			return ""
		}
	}
	
	func saveItem() {
		// This forces a sync with the note text view if the
		// user clicks save while editng the note, since
		// the "end editing" event won't fire in time
		self.textViewDidEndEditing(self.noteTextView)
		
		if let item = self.item {
			item.salesOrder = self.newSalesOrder
			item.orderFillCount = self.newOrderFillCount!
			item.note = self.newNote
			item.allDimensions = self.newAllDimensions!
			
			Api.saveItem(item) { (error: NSError?) in
				NSOperationQueue.mainQueue().addOperationWithBlock() {
					if error {
						if error!.code == 403 {
							let loginViewController = self.storyboard.instantiateViewControllerWithIdentifier("Login View Controller") as UIViewController
							self.view.window.rootViewController = loginViewController
						} else {
							let alertString = error!.localizedDescription
							let alert = UIAlertView(title: "Server Error", message: alertString, delegate: nil, cancelButtonTitle: "Ok")
							alert.show()
						}
					} else {
						self.navigationController.popViewControllerAnimated(true)
					}
				}
			}
		}
	}
}
