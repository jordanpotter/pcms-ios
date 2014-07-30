//
//  LoginViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/27/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var loginOverlay: UIView!
	@IBOutlet weak var loginIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.usernameTextField.delegate = self
		self.usernameTextField.addTarget(self, action: "syncLoginButton", forControlEvents: .EditingChanged)
		
		self.passwordTextField.delegate = self
		self.passwordTextField.addTarget(self, action: "syncLoginButton", forControlEvents: .EditingChanged)
		
		self.syncLoginButton()
		
		
		NSLog("Need to disable logging in automatically")
		self.usernameTextField.text = "jpotter"
		self.passwordTextField.text = "pigbenis"
		self.login()
	}
	
	func syncLoginButton() {
		self.loginButton.enabled = self.usernameTextField.text != "" && self.passwordTextField.text != ""
	}
	
	@IBAction func clickedBackground(sender: UITapGestureRecognizer) {
		self.resignAllResponders()
	}
	
	func resignAllResponders() {
		self.usernameTextField.resignFirstResponder()
		self.passwordTextField.resignFirstResponder()
	}
	
	func textFieldShouldReturn(textField: UITextField!) -> Bool {
		if textField == self.usernameTextField {
			self.passwordTextField.becomeFirstResponder()
			return false
		} else if textField == self.passwordTextField {
			self.login()
			return false
		}
		
		return true
	}
	
	@IBAction func login() {
		self.resignAllResponders()
		self.loginOverlay.hidden = false
		self.loginIndicator.startAnimating()
		
		Api.login(self.usernameTextField.text, password: self.passwordTextField.text) { (requestError: NSError?) in
			NSOperationQueue.mainQueue().addOperationWithBlock() {
				self.loginOverlay.hidden = true
				self.loginIndicator.stopAnimating()
				
				if let error = requestError {
					NSLog("Error while logging in: %@", error)
					let errorMessage = "Unable to login. Make sure your username and password are correct"
					let alert = UIAlertView(title: "Server Error", message: errorMessage, delegate: nil, cancelButtonTitle: "Ok")
					alert.show()
				} else {
					let mainAppSplitViewController = self.storyboard.instantiateViewControllerWithIdentifier("Main App Split View Controller") as UIViewController
					self.view.window.rootViewController = mainAppSplitViewController

//					self.performSegueWithIdentifier("display main app", sender: self)
				}
			}
		}
	}
}
