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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.usernameTextField.delegate = self
		self.usernameTextField.addTarget(self, action: "syncLoginButton", forControlEvents: .EditingChanged)
		
		self.passwordTextField.delegate = self
		self.passwordTextField.addTarget(self, action: "syncLoginButton", forControlEvents: .EditingChanged)
		
		self.syncLoginButton()
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
		NSLog("Need to perform login!")
		
		self.performSegueWithIdentifier("display main app", sender: self)
	}
}
