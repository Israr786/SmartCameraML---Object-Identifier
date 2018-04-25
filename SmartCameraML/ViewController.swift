//
//  ViewController.swift
//  SmartCameraML
//
//  Created by Apple on 4/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        
        let previewLAyer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLAyer)
        previewLAyer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label:"vidoeQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       // print("Camera was able to capture a frame",Date())
        
        guard  let pixelBUffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
        //check error
    //        print(finishedReq.results)
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            
            print(firstObservation.identifier,firstObservation.confidence)
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer:pixelBUffer , options:[:]).perform([request])

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

