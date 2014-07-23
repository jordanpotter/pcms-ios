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
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func vibrate() {
		AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
	}
}
