//
//  ScannedItemsTableViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

let ADDED_ITEM_NOTIFICATION = "added item notification"
let REMOVED_ITEM_NOTIFICATION = "removed item notification"
let REMOVED_ALL_ITEMS_NOTIFICATION = "removed all items notification"

class ScannedItemsTableViewController: UITableViewController {
	var currentItems = Array<Item>()
	var retrievingItem = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = ""
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
	
	func processNewItem(notification: NSNotification!) {
		if self.retrievingItem {
			return
		}
		
		if let itemIdString: NSString = notification.object as? NSString {
			let itemId = itemIdString.integerValue
			if self.currentItems.filter({$0.id == itemId}).count == 0 {
				self.retrievingItem = true
				Api.retrieveItem(itemId) { (item: Item?, error: NSError?) in
					self.retrievingItem = false
					
					NSOperationQueue.mainQueue().addOperationWithBlock() {
						if error {
							let alertString = error!.localizedDescription
							let alert = UIAlertView(title: "Server Error", message: alertString, delegate: nil, cancelButtonTitle: "Ok")
							alert.show()
						} else if item {
							self.currentItems.append(item!)
							self.tableView.reloadData()
							
							NSNotificationCenter.defaultCenter().postNotificationName(ADDED_ITEM_NOTIFICATION, object: item)
						}
					}
				}
			}
		}
	}
	
	func clearItems() {
		self.currentItems.removeAll(keepCapacity: false)
		self.tableView.reloadData()
		NSNotificationCenter.defaultCenter().postNotificationName(REMOVED_ALL_ITEMS_NOTIFICATION, object: nil)
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
		let removedItem = self.currentItems.removeAtIndex(indexPath.row)
		self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		NSNotificationCenter.defaultCenter().postNotificationName(REMOVED_ITEM_NOTIFICATION, object: removedItem)
	}
}
