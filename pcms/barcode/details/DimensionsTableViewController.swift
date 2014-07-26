//
//  DimensionsTableViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/26/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class DimensionsTableViewController: UITableViewController {
	var itemDimensions = Array<ItemDimensions>()
	
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "show dimension details" {
			let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()
			let selectedDimension = self.itemDimensions[indexPath.row]
			
//			let itemDetailsViewController: ItemDetailsViewController = segue.destinationViewController as ItemDetailsViewController
//			itemDetailsViewController.item = selectedItem
		}
	}
	
	override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		return self.itemDimensions.count
	}
	
	override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		if let cell = tableView?.dequeueReusableCellWithIdentifier("item dimensions cell") as? DimensionsTableViewCell {
			let dimensions = self.itemDimensions[indexPath!.row]
			cell.length = dimensions.length
			cell.width = dimensions.width
			cell.area = dimensions.area
			return cell
		} else {
			return nil
		}
	}
}
