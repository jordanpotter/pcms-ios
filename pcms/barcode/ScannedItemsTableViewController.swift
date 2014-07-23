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
	
	override func viewWillAppear(animated: Bool) {
		super.viewDidAppear(animated)
		NSNotificationCenter.defaultCenter().addObserverForName(NEW_ITEM_NOTIFICATION, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:processNewItem)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:NEW_ITEM_NOTIFICATION, object:nil)
	}
	
	func processNewItem(notification: NSNotification!) {
		if let itemId: NSString = notification.object as? NSString {
			if self.currentItems.filter({$0.id == itemId}).count == 0 {
				let item = Item(id: itemId)
				self.currentItems.append(item)
				self.tableView.reloadData()
				self.vibrateDevice()
			}
		}
	}
	
	func vibrateDevice() {
		AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		return currentItems.count
	}
	
	override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		let cell = tableView?.dequeueReusableCellWithIdentifier("scanned item cell") as? UITableViewCell
		cell!.textLabel.text = self.currentItems[indexPath!.row].id
		return cell
	}
}
