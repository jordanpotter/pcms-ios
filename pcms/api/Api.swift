//
//  Api.swift
//  pcms
//
//  Created by Jordan Potter on 7/28/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation

let apiRootUrl = "http://pcms-staging.herokuapp.com/api/"

struct Api {
	
	static func setBody(request: NSMutableURLRequest, data: NSData) {
		request.setValue(data.length.bridgeToObjectiveC().stringValue, forHTTPHeaderField: "Content-Length")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = data
	}
	
	static func performRequest(url: NSURL, bodyData: NSData?, method: String, completionHandler: (NSData?, NSError?) -> Void) {
		let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
		if bodyData { Api.setBody(request, data: bodyData!) }
		request.HTTPMethod = method
		
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) in
			if error {
				completionHandler(nil, error)
			} else {
				let statusCode = (response as NSHTTPURLResponse).statusCode
				if statusCode < 200 || statusCode > 299 {
					let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
					completionHandler(nil, NSError(domain: errorString, code: statusCode, userInfo: nil))
				} else {
					completionHandler(data, nil)
				}
			}
		}
	}
	
	static func login(username: String, password: String, completionHandler: ((NSError?) -> Void)?) {
		let postDictionary = ["username": username, "password": password]
		
		var error: NSError?
		let postData = NSJSONSerialization.dataWithJSONObject(postDictionary, options: NSJSONWritingOptions(0), error: &error)
		if error {
			completionHandler?(error)
			return
		}
		
		let url = NSURL(string: apiRootUrl + "login")
		Api.performRequest(url, bodyData: postData, method: "POST") { (data: NSData?, error: NSError?) in
			if completionHandler { completionHandler!(error) }
		}
	}
	
	static func logout(completionHandler: ((NSError?) -> Void)?) {
		let url = NSURL(string: apiRootUrl + "logout")
		Api.performRequest(url, bodyData: nil, method: "POST") { (data: NSData?, error: NSError?) in
			if completionHandler { completionHandler!(error) }
		}
	}
	
	static func retrieveItem(serial: String, completionHandler: (Item?, NSError?) -> Void) {
		let url = NSURL(string: apiRootUrl + "films/\(serial)")
		Api.performRequest(url, bodyData: nil, method: "GET") { (data: NSData?, error: NSError?) in
			if error {
				completionHandler(nil, error)
				return
			}
			
			var jsonError: NSError?
			if let itemJson = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? NSDictionary {
				completionHandler(Item(json: itemJson), nil)
			} else if jsonError {
				completionHandler(nil, jsonError)
			} else {
				completionHandler(nil, NSError(domain: "Server data poorly formed", code: 500, userInfo: nil))
			}
		}
	}
	
	static func saveItem(item: Item, completionHandler: ((NSError?) -> Void)?) {
		let jsonedItem = item.toJson()
		if jsonedItem.error {
			completionHandler?(jsonedItem.error)
			return
		}
		
		let url = NSURL(string: apiRootUrl + "films/\(item.id)")
		Api.performRequest(url, bodyData: jsonedItem.data!, method: "PUT") { (data: NSData?, error: NSError?) in
			if completionHandler { completionHandler!(error) }
		}
	}
	
	static func saveItemsPhase(items: Array<Item>, phase: String, completionHandler: ((NSError?) -> Void)?) {
		var ids = Array<Int>()
		for item in items {
			ids.append(item.id)
		}
		
		let postDictionary = ["films_ids": ids, "phase": phase]
		
		var error: NSError?
		let postData = NSJSONSerialization.dataWithJSONObject(postDictionary, options: NSJSONWritingOptions(0), error: &error)
		if error {
			completionHandler?(error)
			return
		}
		
		let url = NSURL(string: apiRootUrl + "films/update_multiple")
		Api.performRequest(url, bodyData: postData, method: "PUT") { (data: NSData?, error: NSError?) in
			if completionHandler { completionHandler!(error) }
		}
	}
	
	static func saveItemsShelf(items: Array<Item>, shelf: String, completionHandler: ((NSError?) -> Void)?) {
		var ids = Array<Int>()
		for item in items {
			ids.append(item.id)
		}
		
		let postDictionary = ["films_ids": ids, "shelf": shelf]
		
		var error: NSError?
		let postData = NSJSONSerialization.dataWithJSONObject(postDictionary, options: NSJSONWritingOptions(0), error: &error)
		if error {
			completionHandler?(error)
			return
		}
		
		let url = NSURL(string: apiRootUrl + "films/update_multiple")
		Api.performRequest(url, bodyData: postData, method: "PUT") { (data: NSData?, error: NSError?) in
			if completionHandler { completionHandler!(error) }
		}
	}
	
	static func retrieveSalesOrders(completionHandler: (Array<String>?, NSError?) -> Void) {
		let url = NSURL(string: apiRootUrl + "films/assignable_orders")
		Api.performRequest(url, bodyData: nil, method: "GET") { (data: NSData?, error: NSError?) in
			if error {
				completionHandler(nil, error)
				return
			}
			
			var jsonError: NSError?
			if let jsonedSalesOrders = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? NSDictionary {
				var salesOrders = Array<String>()
				for jsonedSalesOrder in jsonedSalesOrders["assignable_orders"] as Array<NSDictionary> {
					if let salesOrder = jsonedSalesOrder["code"] as? String {
						salesOrders.append(salesOrder)
					}
				}
				completionHandler(salesOrders, jsonError)
			} else if jsonError {
				completionHandler(nil, jsonError)
			} else {
				completionHandler(nil, NSError(domain: "Server data poorly formed", code: 500, userInfo: nil))
			}
		}
	}
}
