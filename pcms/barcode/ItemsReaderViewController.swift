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

enum ItemsReaderState {
	case Default
	case SettingPhase
}

class ItemsReaderViewController: UIViewController, UIActionSheetDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	var state: ItemsReaderState = .Default
	var scannedItemsTableViewController: ScannedItemsTableViewController?
	var allowedPhases = Array<String>()
	var clearItemsButton: UIBarButtonItem?
	var setPhaseButton: UIBarButtonItem?
	var cancelSetPhaseButton: UIBarButtonItem?
	var batchUpdatePhaseButton: UIBarButtonItem?
	var batchUpdateShelfButton: UIBarButtonItem?
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.clearItemsButton = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: "clearItems")
		self.batchUpdatePhaseButton = UIBarButtonItem(image: UIImage(named: "phase"), style: .Plain, target: self, action: "showBatchPhaseUpdate")
		self.batchUpdateShelfButton = UIBarButtonItem(image: UIImage(named: "shelf"), style: .Plain, target: self, action: "showBatchShelfUpdate")
		self.setPhaseButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "setPhase")
		self.cancelSetPhaseButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSetPhase")
		
		self.batchUpdateShelfAlert = UIAlertView()
		self.batchUpdateShelfAlert!.delegate = self
		self.batchUpdateShelfAlert!.title = "Modify Shelf"
		self.batchUpdateShelfAlert!.alertViewStyle = .PlainTextInput
		self.batchUpdateShelfAlert!.addButtonWithTitle("Ok")
		self.batchUpdateShelfAlert!.addButtonWithTitle("Cancel")
		self.batchUpdateShelfAlert!.cancelButtonIndex = 1
		
		self.phasePicker.delegate = self
		self.phasePicker.dataSource = self
		
		self.syncUI()
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

	func syncUI() {
		switch self.state {
		case .Default where self.currentItems.isEmpty:
			self.title = nil
			self.phasePicker.hidden = true
			self.phasePickerOverlay.hidden = true
			self.navigationItem.leftBarButtonItem = nil
			self.navigationItem.rightBarButtonItems = []
		case .Default:
			self.title = nil
			self.phasePicker.hidden = true
			self.phasePickerOverlay.hidden = true
			self.navigationItem.leftBarButtonItem = self.clearItemsButton
			self.navigationItem.rightBarButtonItems = [self.batchUpdateShelfButton!, self.batchUpdatePhaseButton!]
		case .SettingPhase:
			self.title = "Phase"
			self.phasePicker.hidden = false
			self.phasePickerOverlay.hidden = false
			self.navigationItem.leftBarButtonItem = self.cancelSetPhaseButton
			self.navigationItem.rightBarButtonItems = [self.setPhaseButton!]
		}
	}
	
	func vibrateDevice() {
		AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
	}
	
	func itemAdded(notification: NSNotification!) {
		self.allowedPhases = Item.getAllowedPhasesForItems(self.currentItems)
		self.phasePicker.reloadAllComponents()
		self.syncUI()
		self.vibrateDevice()
	}
	
	func itemRemoved(notification: NSNotification!) {
		self.allowedPhases = Item.getAllowedPhasesForItems(self.currentItems)
		self.phasePicker.reloadAllComponents()
		self.syncUI()
	}
	
	func clearItems() {
		if let scannedItemsTableViewController = self.scannedItemsTableViewController {
			scannedItemsTableViewController.clearItems()
		}
	}
	
	func showBatchPhaseUpdate() {
		self.state = .SettingPhase
		self.syncUI()
	}
	
	func setPhase() {
		let phase = self.allowedPhases[self.phasePicker.selectedRowInComponent(0)]
		for item in self.currentItems {
			item.phase = phase
		}
		
		self.state = .Default
		self.syncUI()
		
		if let scannedItemsTableViewController = self.scannedItemsTableViewController {
			scannedItemsTableViewController.tableView.reloadData()
		}
		
		Api.saveItemsPhase(self.currentItems, phase: phase) { (error: NSError?) in
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
				}
			}
		}
	}
	
	func cancelSetPhase() {
		self.state = .Default
		self.syncUI()
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
		let shelf = self.batchUpdateShelfAlert!.textFieldAtIndex(0).text
		for item in self.currentItems {
			item.shelf = shelf
		}
		
		if let scannedItemsTableViewController = self.scannedItemsTableViewController {
			scannedItemsTableViewController.tableView.reloadData()
		}
		
		Api.saveItemsShelf(self.currentItems, shelf: shelf) { (error: NSError?) in
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
				}
			}
		}
	}
	
	func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
		if alertView == self.batchUpdateShelfAlert {
			if buttonIndex == 0 {
				self.setShelf()
			}
		}
	}
}
