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

class ScannedItemsTableViewController: UITableViewController {
	var currentItems = Array<Item>()
	var clearItemsButton: UIBarButtonItem?
	var batchUpdateButton: UIBarButtonItem?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.clearItemsButton = UIBarButtonItem(title: "Clear All", style: .Plain, target: self, action: "clearItems")
		self.batchUpdateButton = UIBarButtonItem(title: "Modify", style: .Plain, target: self, action: "batchUpdate")

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
		} else if segue.identifier == "show batch update" {
			let batchUpdateViewController = segue.destinationViewController as BatchUpdateViewController
			batchUpdateViewController.currentItems = self.currentItems
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
		
		self.updateButtons()
	}
	
	func clearItems() {
		self.currentItems.removeAll(keepCapacity: false)
		self.tableView.reloadData()
		self.updateButtons()
	}
	
	func batchUpdate() {
		self.performSegueWithIdentifier("show batch update", sender: self)
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
