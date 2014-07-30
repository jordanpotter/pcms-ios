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
	let scannerOutput = AVCaptureMetadataOutput()
	var scannerPreviewLayer: AVCaptureVideoPreviewLayer?
	var lastScanTime: NSDate
	
	init(coder aDecoder: NSCoder!) {
		self.lastScanTime = NSDate.date()
		super.init(coder: aDecoder)
		self.setupScanner()
	}
	
	init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
		self.lastScanTime = NSDate.date()
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.setupScanner()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.scannerSession.startRunning()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.addScannerPreview()
		self.syncScannerPreviewOrientation()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.scannerSession.stopRunning()
		
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIDeviceOrientationDidChangeNotification, object:nil)
	}
	
	func orientationChanged(notification: NSNotification!) {
		self.syncScannerPreviewOrientation()
	}
	
	func setupScanner() {
		self.setupScannerInput() && self.setupScannerConfiguration() && self.setupScannerOutput()
	}
	
	func setupScannerInput() -> Bool {
		var scannerError: NSError?
		self.scannerInput = AVCaptureDeviceInput.deviceInputWithDevice(scannerDevice, error: &scannerError) as? AVCaptureDeviceInput
		
		if let error = scannerError {
			NSLog("Error while creating barcode scanner input: %@", error)
			let alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
			alert.show()
			return false
		} else {
			self.scannerSession.addInput(self.scannerInput)
			return true
		}
	}

	func setupScannerConfiguration() -> Bool {
		var lockError: NSError?
		self.scannerDevice.lockForConfiguration(&lockError)
		if let error = lockError {
			NSLog("Error while configuring barcode scanner: %@", error)
			let alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
			alert.show()
			return false
		}
		
		if self.scannerDevice.autoFocusRangeRestrictionSupported {
			self.scannerDevice.autoFocusRangeRestriction = .Near
		}
		
		if self.scannerDevice.focusPointOfInterestSupported {
			self.scannerDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
		}
		
		self.scannerDevice.unlockForConfiguration()
		return true
	}

	func setupScannerOutput() -> Bool {
		self.scannerOutput.setMetadataObjectsDelegate(self, queue:dispatch_get_main_queue())
		self.scannerSession.addOutput(self.scannerOutput)
		self.scannerOutput.metadataObjectTypes = self.scannerOutput.availableMetadataObjectTypes
		return true
	}

	func addScannerPreview() {
		if self.scannerPreviewLayer {
			return
		}
		
		self.scannerPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(self.scannerSession) as? AVCaptureVideoPreviewLayer
		if self.scannerPreviewLayer {
			self.scannerPreviewLayer!.frame = self.view.frame
			self.scannerPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
			self.view.layer.addSublayer(scannerPreviewLayer)
		} else {
			NSLog("Error while setting up barcode scanner preview layer")
			let alert = UIAlertView(title: "Error", message: "Unable to create barcode scanner preview", delegate: nil, cancelButtonTitle: "Ok")
			alert.show()
		}
	}
	
	func syncScannerPreviewOrientation() {
		if let scannerPreviewLayer = self.scannerPreviewLayer {
			switch (UIDevice.currentDevice().orientation) {
			case UIDeviceOrientation.LandscapeLeft:
				self.scannerPreviewLayer!.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI + M_PI_2)))
			case UIDeviceOrientation.LandscapeRight:
				self.scannerPreviewLayer!.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI_2)))
			case UIDeviceOrientation.PortraitUpsideDown:
				self.scannerPreviewLayer!.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI)))
			default:
				self.scannerPreviewLayer!.setAffineTransform(CGAffineTransformMakeRotation(0.0))
			}
		}
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)  {
		let enoughTimeHasPassed = self.lastScanTime.dateByAddingTimeInterval(0.5).compare(NSDate.date()) == NSComparisonResult.OrderedAscending
		if !enoughTimeHasPassed {
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