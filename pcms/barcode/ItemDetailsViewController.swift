//
//  ItemDetailsViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/23/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit

class ItemDetailsViewController: UIViewController {
	var item: Item?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = self.item?.id
	}
}
