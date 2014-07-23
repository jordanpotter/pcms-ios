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

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	let scannerSession = AVCaptureSession()
	let scannerDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
	var scannerInput: AVCaptureDeviceInput?
	var scannerOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
	
	init(coder aDecoder: NSCoder!) {
		super.init(coder: aDecoder)
		setScannerInput()
		setScannerConfiguration()
		setScannerOutput()
	}
	
	init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setScannerInput()
		setScannerConfiguration()
		setScannerOutput()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setScannerPreview()
		scannerSession.startRunning()
	}
	
	func setScannerInput() {
		var scannerError: NSError?
		self.scannerInput = AVCaptureDeviceInput.deviceInputWithDevice(scannerDevice, error: &scannerError) as? AVCaptureDeviceInput
		
		if let error = scannerError {
			NSLog("Error while creating barcode scanner input: %@", error)
		} else {
			self.scannerSession.addInput(self.scannerInput)
		}
	}

	func setScannerConfiguration() {
		var lockError: NSError?
		scannerDevice.lockForConfiguration(&lockError)
		if let error = lockError {
			NSLog("Error while configuring barcode scanner: %@", error)
			return
		}
		
		if scannerDevice.autoFocusRangeRestrictionSupported {
			scannerDevice.autoFocusRangeRestriction = .Near
		}
		
		scannerDevice.unlockForConfiguration()
	}

	func setScannerOutput() {
		self.scannerOutput.setMetadataObjectsDelegate(self, queue:dispatch_get_main_queue())
		self.scannerSession.addOutput(self.scannerOutput)
		self.scannerOutput.metadataObjectTypes = self.scannerOutput.availableMetadataObjectTypes
	}

	func setScannerPreview() {
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
		NSLog("TODO: need to handle captured output")
	}
}
