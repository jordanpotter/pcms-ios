//
//  BarcodeScannerViewController.swift
//  pcms
//
//  Created by Jordan Potter on 7/22/14.
//  Copyright (c) 2014 Jordan Potter. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

let NEW_ITEM_NOTIFICATION = "new item notification"

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	let scannerSession = AVCaptureSession()
	let scannerDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
	var scannerInput: AVCaptureDeviceInput?
	let scannerOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
	var lastScanTime: NSDate
	
	init(coder aDecoder: NSCoder!) {
		self.lastScanTime = NSDate.date()
		super.init(coder: aDecoder)
		setupScanner()
	}
	
	init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
		self.lastScanTime = NSDate.date()
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setupScanner()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		addScannerPreview()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewDidAppear(animated)
		scannerSession.startRunning()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		scannerSession.stopRunning()
	}
	
	func setupScanner() {
		setupScannerInput()
		setupScannerConfiguration()
		setupScannerOutput()
	}
	
	func setupScannerInput() {
		var scannerError: NSError?
		self.scannerInput = AVCaptureDeviceInput.deviceInputWithDevice(scannerDevice, error: &scannerError) as? AVCaptureDeviceInput
		
		if let error = scannerError {
			NSLog("Error while creating barcode scanner input: %@", error)
		} else {
			self.scannerSession.addInput(self.scannerInput)
		}
	}

	func setupScannerConfiguration() {
		var lockError: NSError?
		scannerDevice.lockForConfiguration(&lockError)
		if let error = lockError {
			NSLog("Error while configuring barcode scanner: %@", error)
			return
		}
		
		if scannerDevice.autoFocusRangeRestrictionSupported {
			scannerDevice.autoFocusRangeRestriction = .Near
		}
		
		if scannerDevice.focusPointOfInterestSupported {
			scannerDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
		}
		
		scannerDevice.unlockForConfiguration()
	}

	func setupScannerOutput() {
		self.scannerOutput.setMetadataObjectsDelegate(self, queue:dispatch_get_main_queue())
		self.scannerSession.addOutput(self.scannerOutput)
		self.scannerOutput.metadataObjectTypes = self.scannerOutput.availableMetadataObjectTypes
	}

	func addScannerPreview() {
		let previewLayer: AnyObject! = AVCaptureVideoPreviewLayer.layerWithSession(self.scannerSession)
		if let scannerPreviewLayer: AVCaptureVideoPreviewLayer = previewLayer as? AVCaptureVideoPreviewLayer {
			scannerPreviewLayer.frame = self.view.frame
			scannerPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
			self.view.layer.addSublayer(scannerPreviewLayer)
		} else {
			NSLog("Error while setting up barcode scanner preview layer")
		}
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)  {
		if self.lastScanTime.dateByAddingTimeInterval(0.5).compare(NSDate.date()) != NSComparisonResult.OrderedAscending {
			return
		}
		
		self.lastScanTime = NSDate.date()
		
		for metadataObject in metadataObjects {
			if let machineReadableCodeObject: AVMetadataMachineReadableCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject {
				NSNotificationCenter.defaultCenter().postNotificationName(NEW_ITEM_NOTIFICATION, object: machineReadableCodeObject.stringValue)
			} else {
				NSLog("Unrecognized type read %@", metadataObject.type)
			}
		}
	}
}