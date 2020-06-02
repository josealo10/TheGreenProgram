//
//  ConfimationEmailPopup.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 1/13/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class ConfirmationEmailPopup: UIViewController {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var Xbtn: UIButton!
    
    var buttonAction: (() -> Void)?
    var username : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        container.layer.cornerRadius = 30
        container.clipsToBounds = true
        
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        btn.backgroundColor = .colorPrimary
        
        Xbtn.backgroundColor = .colorPrimary
    }
    @IBAction func ok_button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        buttonAction?()
    }
    
    @IBAction func x_button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resendConfirmationEmail(_ sender: Any) {
        let (codeSended,errorMessage) = AWS.reSendConfirmationCode(username: username)
        if codeSended{
            Alert.showBasicAlert(on: self, with: "Email sended", message: "We have sent you a verification code to your email")
        }else{
            Alert.showBasicAlert(on: self, with: "Error", message: errorMessage)
        }
        
    }
}
