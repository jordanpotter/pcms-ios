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

class ItemsReaderViewController: UIViewController {
	var currentItems = Dictionary<String, Bool>()
	
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
			if !self.currentItems[itemId] {
				self.currentItems[itemId] = true
				self.vibrateDevice()
				
				NSLog("need to process item \(itemId) here")
			}
		}
	}
	
	func vibrateDevice() {
		AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
	}
}
