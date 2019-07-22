//
//  ViewController.swift
//  RA Face Partner
//
//  Created by Swarup Ghosh on 22/07/19.
//  Copyright © 2019 Swarup Ghosh. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: CameraView!
    
    let captureSession = AVCaptureSession.init()
    let photoOutput = AVCapturePhotoOutput()
    
    func cameraSetup() {
        captureSession.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else {
            print("Unable to add video device input to capture session.")
            return
        }
        captureSession.addInput(videoDeviceInput)
        
        
        guard captureSession.canAddOutput(photoOutput) else {
            print("Unable to add photo output to capture session.")
            return
        }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        
        captureSession.commitConfiguration()
        
        self.cameraView.videoPreviewLayer.session = self.captureSession
        
        captureSession.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Using \(CVWrapper.openCVVersionInfo())")
        cameraSetup()
    }
    
    var detectedFaceCount = 0
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let photoData = photo.fileDataRepresentation()
        
        let image = UIImage(data: photoData!)
        // for front camera use no flip
        detectedFaceCount = detectedFaceCount + CVWrapper.faceDetector(image!, transpose: true, flip: false)
        print("\(detectedFaceCount) face(s) detected so far.")
    }

    @IBAction func clickButton(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

