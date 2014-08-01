//
//  AccountInformation.swift
//  pcms
//
//  Created by Jordan Potter on 7/31/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

// Have to do this until Swift supports class variables...
var accountFullName: String?

class AccountInformation {
	
	class func setFullName(fullName: String?) {
		accountFullName = fullName
	}
	
	class func getFullName() -> String? {
		return accountFullName
	}
}