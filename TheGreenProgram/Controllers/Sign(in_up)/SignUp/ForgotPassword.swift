//
//  ChangePassword.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 1/15/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ForgotPassword: UIViewController {
    @IBOutlet weak var request_code_conteiner: UIView!
    @IBOutlet weak var request_code_btn: UIButton!
    @IBOutlet weak var change_password_conteiner: UIView!
    @IBOutlet weak var change_password_btn: UIButton!
    
    @IBOutlet weak var email_tf: SkyFloatingLabelTextField!
    
    @IBOutlet weak var code_tf: SkyFloatingLabelTextField!
    @IBOutlet weak var newPassword_tf: SkyFloatingLabelTextField!
    @IBOutlet weak var confirm_password_tf: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        request_code_conteiner.layer.cornerRadius = 30
        change_password_conteiner.layer.cornerRadius = 30
        
        request_code_btn.layer.cornerRadius = 15
        change_password_btn.layer.cornerRadius = 15
        
        request_code_conteiner.clipsToBounds = true
        request_code_btn.clipsToBounds = true
        change_password_conteiner.clipsToBounds = true
        change_password_btn.clipsToBounds = true
        
        request_code_btn.backgroundColor = .colorPrimary
        change_password_btn.backgroundColor = .colorPrimary
        
    }
    
    @IBAction func requestCode(_ sender: Any) {
        if email_tf.text != "" {
            let email = email_tf.text?.replacingOccurrences(of: " ", with: "")
            let (codeSended, errorMessage) = AWS.requestCode(email: email!)
            if codeSended{
            Alert.showBasicAlert(on: self, with: "Email sended", message: "We have sent you a verification code to your email")
            }else{
                Alert.showBasicAlert(on: self, with: "Error", message: errorMessage)
            }
        }
        
    }
    
    func validateFields()-> Bool{
        var flag: Bool = true
        if code_tf.text == "" {
            flag = false
        }
        
        if newPassword_tf.text == "" {
            flag = false
        }
        
        if confirm_password_tf.text == "" {
            flag = false
        }
        
        if newPassword_tf.text == confirm_password_tf.text {
            flag = false
        }
        if !flag{ Alert.showBasicAlert(on: self, with: "Error in fields", message: "Verify your information")}
        
        return flag
    }
    
    @IBAction func chagePassword(_ sender: Any) {
        if validateFields(){
            let (isPasswordChanged, errorMessage) = AWS.forgotPassword(email: newPassword_tf.text!, newPassword: newPassword_tf.text!, code: code_tf.text!)
            if isPasswordChanged{
                Alert.showBasicAlert(on: self, with: "Success", message: "Password")
                navigationController?.popViewController(animated: true)
            }else{
                Alert.showBasicAlert(on: self, with: "Error", message: errorMessage)
            }
        }
    }
    
}
