//
//  Api.swift
//  pcms
//
//  Created by Jordan Potter on 7/28/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

let apiRootUrl = "http://pcms-staging.herokuapp.com/"

func performLoginRequest(username: String, password: String, completionHandler: ((NSError?) -> Void)?) {
	let url = NSURL(string: apiRootUrl + "login")
	let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
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

func performRetrieveItemFromServerRequest(serial: String, completionHandler: ((Item?, NSError?) -> Void)?) {
	
	
	completionHandler?(nil, nil)
}

func performSaveItemToServerRequest(item: Item, completionHandler: ((NSError?) -> Void)?) {
	
	
	completionHandler?(nil)
}

func performSaveItemsToServerRequest(items: Array<Item>, completionHandler: ((NSError?) -> Void)?) {
	
	
	completionHandler?(nil)
}
