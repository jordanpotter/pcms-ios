//
//  ItemsReaderViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/22/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class ItemsReaderViewController: UIViewController, UIActionSheetDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	var scannedItemsTableViewController: ScannedItemsTableViewController?
	var allowedPhases = Array<String>()
	var clearItemsButton: UIBarButtonItem?
	var setPhaseButton: UIBarButtonItem?
	var cancelSetPhaseButton: UIBarButtonItem?
	var batchUpdateButton: UIBarButtonItem?
	var batchUpdateActionSheet: UIActionSheet?
	var batchUpdateShelfAlert: UIAlertView?
	
	@IBOutlet weak var phasePicker: UIPickerView!
	@IBOutlet weak var phasePickerOverlay: UIView!
	
	var currentItems: Array<Item> {
		if let scannedItemsTableViewController = self.scannedItemsTableViewController {
			return scannedItemsTableViewController.currentItems
		} else {
			return Array<Item>()
		}
	}
	
	var settingPhase: Bool {
	get {
		return !self.phasePicker.hidden
	}
	set {
		self.phasePicker.hidden = !newValue
		self.phasePickerOverlay.hidden = !newValue
	}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.clearItemsButton = UIBarButtonItem(title: "Clear All", style: .Plain, target: self, action: "clearItems")
		self.batchUpdateButton = UIBarButtonItem(title: "Modify", style: .Plain, target: self, action: "batchUpdate")
		self.setPhaseButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "setPhase")
		self.cancelSetPhaseButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSetPhase")
		
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
		
		self.phasePicker.delegate = self
		self.phasePicker.dataSource = self
		
		self.settingPhase = false
		
		self.updateButtons()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().addObserverForName(ADDED_ITEM_NOTIFICATION, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:itemAdded)
		NSNotificationCenter.defaultCenter().addObserverForName(REMOVED_ITEM_NOTIFICATION, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:itemRemoved)
		NSNotificationCenter.defaultCenter().addObserverForName(REMOVED_ALL_ITEMS_NOTIFICATION, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:itemRemoved)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:ADDED_ITEM_NOTIFICATION, object:nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:REMOVED_ITEM_NOTIFICATION, object:nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:REMOVED_ALL_ITEMS_NOTIFICATION, object:nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "embed scanned items table" {
			self.scannedItemsTableViewController = segue.destinationViewController as? ScannedItemsTableViewController
		}
	}

	func updateButtons() {
		if self.settingPhase {
			self.navigationItem.leftBarButtonItem = self.cancelSetPhaseButton
			self.navigationItem.rightBarButtonItem = self.setPhaseButton
		} else if self.currentItems.isEmpty {
			self.navigationItem.leftBarButtonItem = nil
			self.navigationItem.rightBarButtonItem = nil
		} else {
			self.navigationItem.leftBarButtonItem = self.clearItemsButton
			self.navigationItem.rightBarButtonItem = self.batchUpdateButton
		}
	}
	
	func vibrateDevice() {
		AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
	}
	
	func itemAdded(notification: NSNotification!) {
		self.allowedPhases = Item.getAllowedPhasesForItems(self.currentItems)
		self.phasePicker.reloadAllComponents()
		self.updateButtons()
		self.vibrateDevice()
	}
	
	func itemRemoved(notification: NSNotification!) {
		self.allowedPhases = Item.getAllowedPhasesForItems(self.currentItems)
		self.phasePicker.reloadAllComponents()
		self.updateButtons()
	}
	
	func clearItems() {
		if let scannedItemsTableViewController = self.scannedItemsTableViewController {
			scannedItemsTableViewController.clearItems()
		}
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
	
	func showBatchPhaseUpdate() {
		self.settingPhase = true
		self.updateButtons()
	}
	
	func setPhase() {
		for item in self.currentItems {
			item.phase = self.allowedPhases[self.phasePicker.selectedRowInComponent(0)]
		}
		
		self.settingPhase = false
		self.updateButtons()
		
		if let scannedItemsTableViewController = self.scannedItemsTableViewController {
			scannedItemsTableViewController.tableView.reloadData()
		}
		
		Item.batchSaveToServer(self.currentItems, { (error: NSError?) in
			if error {
				let alertString = error!.localizedDescription
				let alert = UIAlertView(title: "Server Error", message: alertString, delegate: nil, cancelButtonTitle: "Ok")
				alert.show()
			}
		})
	}
	
	func cancelSetPhase() {
		self.settingPhase = false
		self.updateButtons()
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
		if pickerView == self.phasePicker {
			return 1
		} else {
			return 0
		}
	}
	
	func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == self.phasePicker {
			return self.allowedPhases.count
		} else {
			return 0
		}
	}
	
	func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
		if pickerView == self.phasePicker {
			return self.allowedPhases[row]
		} else {
			return ""
		}
	}
	
	func showBatchShelfUpdate() {
		self.batchUpdateShelfAlert!.show()
	}
	
	func setShelf() {
		for item in self.currentItems {
			item.shelf = self.batchUpdateShelfAlert!.textFieldAtIndex(0).text
		}
		
		if let scannedItemsTableViewController = self.scannedItemsTableViewController {
			scannedItemsTableViewController.tableView.reloadData()
		}
		
		Item.batchSaveToServer(self.currentItems, { (error: NSError?) in
			if error {
				let alertString = error!.localizedDescription
				let alert = UIAlertView(title: "Server Error", message: alertString, delegate: nil, cancelButtonTitle: "Ok")
				alert.show()
			}
		})
	}
	
	func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
		if alertView == self.batchUpdateShelfAlert {
			if buttonIndex == 0 {
				self.setShelf()
			}
		}
	}
}
