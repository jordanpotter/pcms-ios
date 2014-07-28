//
//  Api.swift
//  pcms
//
//  Created by Jordan Potter on 7/28/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

let apiRootUrl = "http://pcms-staging.herokuapp.com/"

func login(username: String, password: String, completionHandler: ((NSError?) -> ())?) {
	
	completionHandler?(nil)
}

func retrieveItemFromServer(serial: String, completionHandler: ((Item?, NSError?) -> ())?) {
	
	
	completionHandler?(nil, nil)
}

func saveItemToServer(item: Item, completionHandler: ((NSError?) -> ())?) {
	
	
	completionHandler?(nil)
}

func saveItemsToServer(items: Array<Item>, completionHandler: ((NSError?) -> ())?) {
	
	
	completionHandler?(nil)
}
