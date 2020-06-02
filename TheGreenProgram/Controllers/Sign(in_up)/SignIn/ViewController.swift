//
//  ViewController.swift
//  TheGreenProgram
//
//  Created by Jose Alonso Alfaro Perez on 11/27/19.
//  Copyright © 2019 Jose Alonso Alfaro Perez. All rights reserved.
//king shisher
//sdwebimages
//setting-aplicaciones-almesenamiento y cache

import UIKit
import SkyFloatingLabelTextField

class ViewController: UIViewController {

    @IBOutlet weak var img_logo: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btn_sign_in: UIButton!
    
    @IBOutlet var textField_email: SkyFloatingLabelTextField!
    @IBOutlet var textfield_password: SkyFloatingLabelTextField!
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        
        textfield_password.delegate = self
        textField_email.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Configuration methods
    @objc func tapGestureDone(){
        view.endEditing(true)
    }
    
    func configureView(){
        
        navigationController?.navigationBar.tintColor = .primaryTextColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        contentView.layer.cornerRadius = 30
        contentView.clipsToBounds = true
        
        btn_sign_in.layer.cornerRadius = 15
        btn_sign_in.clipsToBounds = true
        btn_sign_in.backgroundColor = .colorPrimary
        
        img_logo.layer.cornerRadius = 50
        img_logo.clipsToBounds = true
    }
    
    func validateInput()->Bool{
        var flag:Bool = true
        
        if textField_email.text == ""{
            flag = false
        }
        if textfield_password.text == ""{
            flag = false
        }
        
        if !flag {Alert.showBasicAlert(on: self, with: "Missing field", message: "There are fields without fill")}
        return flag
    }
    
    
    //MARK: - View events
    @IBAction func signIn(_ sender: Any) {
        if validateInput() {
            let (isUserSignIn, errorMessage) = AWS.signIn(username: textField_email.text!, password: textfield_password.text!)
            if !isUserSignIn{
                Alert.showBasicAlert(on: self, with: "Error", message: errorMessage)
            }
        }
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textField_email {
            textField.resignFirstResponder()
            textfield_password.becomeFirstResponder()
         } else if textField == textfield_password {
            textField.resignFirstResponder()
         }
        return true
    }
}
