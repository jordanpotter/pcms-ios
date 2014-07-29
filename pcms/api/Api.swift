//
//  Api.swift
//  pcms
//
//  Created by Jordan Potter on 7/28/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

let apiRootUrl = "http://pcms-staging.herokuapp.com/api/"

func setPostDataForRequest(request: NSMutableURLRequest, data: NSData) {
	request.setValue(data.length.bridgeToObjectiveC().stringValue, forHTTPHeaderField: "Content-Length")
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	request.HTTPBody = data
}

func performLoginRequest(username: String, password: String, completionHandler: ((NSError?) -> Void)?) {
	let postDictionary = ["username": username, "password": password]
	
	var error: NSError?
	let postData = NSJSONSerialization.dataWithJSONObject(postDictionary, options: NSJSONWritingOptions(0), error: &error)
	if error {
		completionHandler?(error)
		return
	}
	
	let url = NSURL(string: apiRootUrl + "login")
	let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
	setPostDataForRequest(request, postData)
	request.HTTPMethod = "POST"
	
	NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) in
		if error {
			completionHandler?(error)
		} else {
			let statusCode = (response as NSHTTPURLResponse).statusCode
			if statusCode < 200 || statusCode > 299 {
				let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
				completionHandler?(NSError(domain: errorString, code: statusCode, userInfo: nil))
			} else {
				completionHandler?(nil)
			}
		}
	})
}

func performRetrieveItemFromServerRequest(id: Int, completionHandler: ((Item?, NSError?) -> Void)?) {
	let url = NSURL(string: apiRootUrl + "films/\(id)")
	
	completionHandler?(nil, nil)
}

func performSaveItemToServerRequest(item: Item, completionHandler: ((NSError?) -> Void)?) {
	let url = NSURL(string: apiRootUrl + "films/\(item.id)")
//	PUT OR PATCH REQUEST
	
	completionHandler?(nil)
}

func performSaveItemsToServerRequest(items: Array<Item>, completionHandler: ((NSError?) -> Void)?) {
	let url = NSURL(string: apiRootUrl + "films/update_multiple")
	
//		{
//			"films_ids": [1, 2, 4],
//			"phase": "phase1",
//			"shelf": "d5"
//	}
	
	completionHandler?(nil)
}

func performAssignableSalesOrdersRequest(completionHandler: ((Array<String>?, NSError?) -> Void)?) {
	let url = NSURL(string: apiRootUrl + "films/assignable_orders")
}

