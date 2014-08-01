//
//  LoginStatusViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/31/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class LoginStatusViewController: UIViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.nameLabel.text = AccountInformation.getFullName()
	}
	
	@IBAction func logout() {
		Api.logout() { (error: NSError?) in
			NSOperationQueue.mainQueue().addOperationWithBlock() {
				if error {
					let alertString = error!.localizedDescription
					let alert = UIAlertView(title: "Server Error", message: alertString, delegate: nil, cancelButtonTitle: "Ok")
					alert.show()
				} else {
					let loginViewController = self.storyboard.instantiateViewControllerWithIdentifier("Login View Controller") as UIViewController
					self.view.window.rootViewController = loginViewController
				}
			}
		}
	}
}
