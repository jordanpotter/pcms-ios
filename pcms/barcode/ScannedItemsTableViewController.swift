//
//  ScannedItemsTableViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class ScannedItemsTableViewController: UITableViewController, UIActionSheetDelegate, UIAlertViewDelegate {
	var currentItems = Array<Item>()
	var allowedPhases = Array<String>()
	var clearItemsButton: UIBarButtonItem?
	var batchUpdateButton: UIBarButtonItem?
	var batchUpdateActionSheet: UIActionSheet?
	var batchUpdateShelfAlert: UIAlertView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.clearItemsButton = UIBarButtonItem(title: "Clear All", style: .Plain, target: self, action: "clearItems")
		self.batchUpdateButton = UIBarButtonItem(title: "Modify", style: .Plain, target: self, action: "batchUpdate")
		
		self.batchUpdateActionSheet = UIActionSheet()
		self.batchUpdateActionSheet!.delegate = self
		self.batchUpdateActionSheet!.addButtonWithTitle("Modify Phase")
		self.batchUpdateActionSheet!.addButtonWithTitle("Modify Shelf")
		self.batchUpdateActionSheet!.addButtonWithTitle("Close")
		self.batchUpdateActionSheet!.cancelButtonIndex = 2
		
		self.batchUpdateShelfAlert = UIAlertView()
		self.batchUpdateShelfAlert!.delegate = self
		self.batchUpdateShelfAlert!.title = "Modify Shelf"
		self.batchUpdateShelfAlert!.alertViewStyle = .PlainTextInput
		self.batchUpdateShelfAlert!.addButtonWithTitle("Ok")
		self.batchUpdateShelfAlert!.addButtonWithTitle("Cancel")
		self.batchUpdateShelfAlert!.cancelButtonIndex = 1

		self.updateButtons()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
		
		NSNotificationCenter.defaultCenter().addObserverForName(NEW_ITEM_NOTIFICATION, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:processNewItem)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:NEW_ITEM_NOTIFICATION, object:nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "show item details" {
			let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()
			let selectedItem = self.currentItems[indexPath.row]
			
			let itemDetailsViewController = segue.destinationViewController as ItemDetailsViewController
			itemDetailsViewController.item = selectedItem
		}
	}
	
	func updateButtons() {
		if self.parentViewController {
			if self.currentItems.isEmpty {
				self.parentViewController.navigationItem.leftBarButtonItem = nil
				self.parentViewController.navigationItem.rightBarButtonItem = nil
			} else {
				self.parentViewController.navigationItem.leftBarButtonItem = self.clearItemsButton
				self.parentViewController.navigationItem.rightBarButtonItem = self.batchUpdateButton
			}
		}
	}
	
	func processNewItem(notification: NSNotification!) {
		if let itemSerial: NSString = notification.object as? NSString {
			if self.currentItems.filter({$0.serial == itemSerial}).count == 0 {
				var item = Item(serial: itemSerial)
				
				NSLog("need to pull item info before adding to table")
				item.saturateData(nil)
				
				self.currentItems.append(item)
				self.tableView.reloadData()
				self.vibrateDevice()
			}
		}
		
		self.allowedPhases = getAllowedPhasesForItems(currentItems)		
		self.updateButtons()
	}
	
	func clearItems() {
		self.currentItems.removeAll(keepCapacity: false)
		self.tableView.reloadData()
		self.updateButtons()
	}
	
	func batchUpdate() {
		self.batchUpdateActionSheet?.showInView(self.view)
	}
	
	func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
		if actionSheet == self.batchUpdateActionSheet {
			if buttonIndex == 0 {
				showBatchPhaseUpdate()
			} else if buttonIndex == 1 {
				showBatchShelfUpdate()
			}
		}
	}
	
	func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
		if alertView == self.batchUpdateShelfAlert {
			if buttonIndex == 0 {
				for item in self.currentItems {
					item.shelf = self.batchUpdateShelfAlert!.textFieldAtIndex(0).text
				}
				self.tableView.reloadData()
				batchSaveItems(self.currentItems, nil)
			}
		}
	}
	
	func showBatchPhaseUpdate() {
		
	}
	
	func showBatchShelfUpdate() {
		self.batchUpdateShelfAlert!.show()
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
	
	func vibrateDevice() {
		AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
	}
	
	override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		return currentItems.count
	}
	
	override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		if let cell = tableView?.dequeueReusableCellWithIdentifier("scanned item cell") as? ScannedItemTableViewCell {
			let item = self.currentItems[indexPath!.row]
			cell.serial = item.serial
			cell.phase = item.phase
			cell.shelf = item.shelf
			return cell
		} else {
			return nil
		}
	}
	
	override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)  {
		self.currentItems.removeAtIndex(indexPath.row)
		self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		self.updateButtons()
	}
}
