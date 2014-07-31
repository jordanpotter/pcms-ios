//
//  AlwaysSplitViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/31/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class AlwaysSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
	}
	
	func splitViewController(svc: UISplitViewController!, shouldHideViewController vc: UIViewController!, inOrientation orientation: UIInterfaceOrientation) -> Bool {
		return false
	}
}
