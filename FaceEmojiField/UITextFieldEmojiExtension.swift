//
//  UITextFieldEmojiExtension.swift
//  FaceEmojiField
//
//  Created by Master on 29.06.2022.
//

import UIKit

extension UITextView: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    struct Holder {
        static var mainViewController: UIViewController = UIViewController()
    }
    var mainViewController: UIViewController{
        get {
            return Holder.mainViewController
        }
        set(newValue) {
            Holder.mainViewController = newValue
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
    public func addFaceEmojiButton(parent: UIView, onViewController: UIViewController){
        
        mainViewController = onViewController
        
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "FaceIcon"), for: .normal)
        button.addTarget(self, action: #selector(getEmoji), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        parent.addSubview(button)

        button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
    }

    @objc func getEmoji(){
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
}
