//
//  ViewController.swift
//  Align
//
//  Created by William Rule on 10/16/23.
//
import AVKit
import AVFoundation
import UIKit
import FLAnimatedImage

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    //Capture Session
    var session: AVCaptureSession?
    //Photo Output
    let output = AVCapturePhotoOutput()
    //View Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    //Shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    
    // AVCaptureVideoPreviewLayer for camera preview (non-optional)
    let gifImageView: FLAnimatedImageView = {
            let imageView = FLAnimatedImageView()
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        var isInitialGifPlayed = false

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            view.layer.addSublayer(previewLayer)
            view.addSubview(shutterButton)
            checkCameraPermissions()

            shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            playGif()
        }

        func playGif() {
            let gifName = isInitialGifPlayed ? "Loop" : "Close1"
            let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif")
            let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath!))

            if let gifData = gifData, let gifImage = FLAnimatedImage(animatedGIFData: gifData) {
                gifImageView.animatedImage = gifImage
                view.addSubview(gifImageView)
                gifImageView.center = view.center // Center the GIF view

                if !isInitialGifPlayed {
                    gifImageView.loopCompletionBlock = { [weak self] (count) in
                        self?.isInitialGifPlayed = true
                        self?.playGif()
                    }
                } else {
                    gifImageView.loopCompletionBlock = nil
                }
            }
        }


            


       
    
     override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           previewLayer.frame = view.bounds
           shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 150)
           gifImageView.frame = view.bounds // Set the frame for the GIF view to match the view bounds
       }
    
    private func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video){ [weak self] granted in guard granted else{
                return
            }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    private func setUpCamera(){
            let session = AVCaptureSession()
            if let device = AVCaptureDevice.default(for: .video){
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input){
                        session.addInput(input)
                    }
                    if session.canAddOutput(output){
                        session.addOutput(output)
                    }
                    
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.session = session
                    
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        session.startRunning()
                        
                        DispatchQueue.main.async {
                            self?.session = session
                        }
                    }
                    
                }
                catch{
                    print(error)
                }
            }
        }
    
    
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        
        session?.stopRunning()
        
        capturedImageView = UIImageView(image: image)
        capturedImageView.contentMode = .scaleAspectFill
        capturedImageView.frame = view.bounds
        view.addSubview(capturedImageView)
        
        setupImageReviewButtons()
    }
    
    
    var capturedImageView: UIImageView!
        var saveButton: UIButton!
        var retakeButton: UIButton!

        func setupImageReviewButtons() {
            saveButton = UIButton(frame: CGRect(x: -20, y: view.frame.size.height - 200, width: 300, height: 200))
            // Set the background image for the save button
            saveButton.setBackgroundImage(UIImage(named: "Save"), for: .normal)
            saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
            
            retakeButton = UIButton(frame: CGRect(x: view.frame.size.width - 240, y: view.frame.size.height - 200, width: 300, height: 200))
            // Set the background image for the retake button
            retakeButton.setBackgroundImage(UIImage(named: "Retake"), for: .normal)
            retakeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)
            
            view.addSubview(saveButton)
            view.addSubview(retakeButton)
        }

        @objc func savePhoto() {
            // Your saving code here
            
            returnToCameraView()
        }
        
        @objc func retakePhoto() {
            returnToCameraView()
        }
        
        func returnToCameraView() {
            capturedImageView.removeFromSuperview()
            saveButton.removeFromSuperview()
            retakeButton.removeFromSuperview()
            session?.startRunning()
        }

//        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//            guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
//                return
//            }
//
//            session?.stopRunning()
//
//            capturedImageView = UIImageView(image: image)
//            capturedImageView.contentMode = .scaleAspectFill
//            capturedImageView.frame = view.bounds
//            view.addSubview(capturedImageView)
//
//            setupImageReviewButtons()
//        }

}


