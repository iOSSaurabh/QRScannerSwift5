//
//  ViewController.swift
//  Demo_QRCode_Scanner
//
//  Created by Saurabh Sharma on 17/06/20.
//  Copyright © 2020 saurabh. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    @IBOutlet weak var labelOutput: UILabel!
    @IBOutlet weak var viewScanBg: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        

               
    }
    
    func failed() {
           let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: "OK", style: .default))
           present(ac, animated: true)
           captureSession = nil
       }

       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)

           if (captureSession?.isRunning == false) {
               captureSession.startRunning()
           }
       }

       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)

           if (captureSession?.isRunning == true) {
               captureSession.stopRunning()
           }
       }

       func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
           captureSession.stopRunning()

           if let metadataObject = metadataObjects.first {
               guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
               guard let stringValue = readableObject.stringValue else { return }
               AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
               found(code: stringValue)
           }

           dismiss(animated: true)
       }

       func found(code: String) {
           print(code)
        labelOutput.text = code
       }

       override var prefersStatusBarHidden: Bool {
           return true
       }

       override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return .portrait
       }


    @IBAction func buttonStart(_ sender: Any) {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
               let videoInput: AVCaptureDeviceInput

               do {
                   videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
               } catch {
                   return
               }

               if (captureSession.canAddInput(videoInput)) {
                   captureSession.addInput(videoInput)
               } else {
                   failed()
                   return
               }

               let metadataOutput = AVCaptureMetadataOutput()

               if (captureSession.canAddOutput(metadataOutput)) {
                   captureSession.addOutput(metadataOutput)

                   metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                   metadataOutput.metadataObjectTypes = [.qr]
               } else {
                   failed()
                   return
               }

               previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
               previewLayer.frame = self.viewScanBg.layer.bounds
               previewLayer.videoGravity = .resizeAspectFill
        self.viewScanBg.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    @IBAction func buttonStop(_ sender: Any) {
        captureSession?.stopRunning()
    }
}

