//
//  UITextFieldEmojiExtension.swift
//  FaceEmojiField
//
//  Created by Master on 29.06.2022.
//

import UIKit
import AVFoundation

extension UITextView: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate{
    
    struct Holder {
        static var mainViewController: UIViewController = UIViewController()
        static var photoOutput = AVCapturePhotoOutput()
        static var lastEmotion = "🤷🏻‍♂️"
        static var button = UIButton(type: .system)
    }
    var mainViewController: UIViewController{
        get {
            return Holder.mainViewController
        }
        set(newValue) {
            Holder.mainViewController = newValue
        }
    }
    var photoOutput: AVCapturePhotoOutput{
        get {
            return Holder.photoOutput
        }
        set(newValue) {
            Holder.photoOutput = newValue
        }
    }
    var lastEmotion: String{
        get {
            return Holder.lastEmotion
        }
        set(newValue) {
            Holder.lastEmotion = newValue
        }
    }
    var button: UIButton{
        get {
            return Holder.button
        }
        set(newValue) {
            Holder.button = newValue
        }
    }
    
    
    
    public func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        DispatchQueue.global(qos: .userInteractive).async {
            Predictor().predict(image: image, complition: self.showPred)
        }
        picker.dismiss(animated: true)
    }
    
    func showPred(_ predictions: [Prediction]?) {
        DispatchQueue.main.async {
            self.text += "\(Emoji(emotion: predictions?.first?.0 ?? ""))"
        }
    }
    func showPred2(_ predictions: [Prediction]?) {
        DispatchQueue.main.async {
            self.lastEmotion = "\(Emoji(emotion: predictions?.first?.0 ?? ""))"
            self.button.setTitle(self.lastEmotion, for: .normal)
        }
    }
    
    public func addFaceEmojiButton(parent: UIView, onViewController: UIViewController, withPicker: Bool){
        
        mainViewController = onViewController
        
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "FaceIcon"), for: .normal)
        button.addTarget(self, action: withPicker ?
                            #selector(getEmojiWithPicker) :
                            #selector(getEmojiWithoutPicker),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        parent.addSubview(button)

        button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
    }
    public func addFaceEmojiLiveButton(parent: UIView, onViewController: UIViewController){
        
        mainViewController = onViewController
        
        //button.setBackgroundImage(UIImage(named: "FaceIcon"), for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont(name: "ArialMT", size: self.frame.height)
        button.setTitle(self.lastEmotion, for: .normal)
        button.addTarget(self,
                         action: #selector(setEmoji) ,
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        parent.addSubview(button)

        button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        Timer.scheduledTimer(withTimeInterval: 2,
                                     repeats: true,
                                     block: { _ in
                                        DispatchQueue.global(qos: .userInteractive).async {
                                            self.openCamera()
                                        }
                                     })
    }

    @objc func setEmoji(){
        DispatchQueue.main.async {
            self.text += self.lastEmotion
        }
    }
    @objc func getEmojiWithPicker(){
        let impicVC = UIImagePickerController()
        impicVC.delegate = self
        impicVC.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            impicVC.sourceType = .camera
        }
        else{
            impicVC.sourceType = .photoLibrary
        }
        mainViewController.present(impicVC, animated: true)
    }
    
    @objc func getEmojiWithoutPicker(){
        openCamera()
    }
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .front){
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let _ = AVCaptureVideoPreviewLayer(session: captureSession)
            
            captureSession.startRunning()
            
            usleep(200_000)
            
            let photoSettings = AVCapturePhotoSettings()
            if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
                photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let previewImage = UIImage(data: imageData) else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            Predictor().predict(image: previewImage, complition: self.showPred2)
        }
    }
    
    @objc private func handleDismiss() {
        
    }
}
