//
//  CreateAccount.swift
//  TheGreenProgram
//
//  Created by Jose Alonso Alfaro Perez on 11/27/19.
//  Copyright © 2019 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

import UIKit
import DLRadioButton
import SkyFloatingLabelTextField
import maskedTextField


class CreateAccount: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var image_logo: UIImageView!
    
    @IBOutlet weak var personal_information_conteiner: UIView!
    @IBOutlet weak var access_information_conteiner: UIView!
    
    @IBOutlet weak var create_account_btn: UIButton!
    
    @IBOutlet weak var birthday_tf: UITextField!
    
    @IBOutlet weak var name_tf: SkyFloatingLabelTextField!
    @IBOutlet weak var family_name_tf: SkyFloatingLabelTextField!
    @IBOutlet weak var email_tf: SkyFloatingLabelTextField!
    
    @IBOutlet weak var exNumber_tf: SkyFloatingLabelTextField!
    @IBOutlet weak var number_tf: SkyFloatingLabelTextField!
    @IBOutlet weak var address_btn: UIButton!
    @IBOutlet weak var password_tf: SkyFloatingLabelTextField!
    @IBOutlet weak var confirm_password_tf: SkyFloatingLabelTextField!
    
    @IBOutlet weak var male_btn: DLRadioButton!
    @IBOutlet weak var female_btn: DLRadioButton!
    
    @IBOutlet weak var bottonConstraint: NSLayoutConstraint!
    
    let confimationPop = ConfirmationEmailPopup()
    
    var birthdaySelected: String = ""
    
    var birthdayPicker: UIDatePicker?
    
    var address:String = ""

    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setVisualComponents()
        createBirthdayPicker()
        createToolbar()
        Profile.address = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        self.view.addGestureRecognizer(tapGesture)
        
        name_tf.delegate = self
        family_name_tf.delegate = self
        
        email_tf.delegate = self
        password_tf.delegate = self
        confirm_password_tf.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Profile.address != ""{
            address = Profile.address
            address_btn.setTitle(Profile.address, for: .normal)
        }
    }
    
    //MARK: - Create account
    @IBAction func create_account(_ sender: Any) {
        
        if !validateInputs() {
            return
        }
        
        let gender: String!
        if male_btn.isSelected{
            gender = "Male"
        }else{
            gender = "Female"
        }
        
        var phoneNumber = exNumber_tf.text
        phoneNumber = "+" + phoneNumber!
        phoneNumber = phoneNumber! + number_tf.text!
        phoneNumber = phoneNumber!.replacingOccurrences(of: " ", with: "")
        
        let (successfullSignUp,errorMessage) = AWS.singUp(
            email: email_tf.text ?? "",
            password: password_tf.text!,
            name: name_tf.text!,
            surname: family_name_tf.text!,
            birthdate: birthdaySelected,
            phone: phoneNumber!,
            address: address,
            gender: gender,
            latitude: String(Profile.latitude),
            longitude: String(Profile.longitude))
        
        
        if successfullSignUp{
            let popUp = preparePopUp(){ [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            self.present(popUp, animated:true)
        }else{
            Alert.showBasicAlert(on: self, with: "Error", message: errorMessage)
        }
        
    }
    
    func preparePopUp(completion: @escaping () -> Void) -> ConfirmationEmailPopup {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "confimation_email_popup") as! ConfirmationEmailPopup
        
        alertVC.buttonAction = completion
        alertVC.username = email_tf.text
        
        return alertVC
    }
    
    //MARK: - Validations
    func validateInputs() -> Bool {
        var flag: Bool = true
        var message: String = ""
        if name_tf.text == "" {
            flag = false
            message = "Name field missing"
        }
        if family_name_tf.text == "" {
            message = "Surname field missing"
            flag = false
        }
        
        if exNumber_tf.text == ""{
            message = "Enter a valid phone number"
            flag = false
        }else if number_tf.text == ""{
            message = "Enter a valid phone number"
            flag = false
        }else{
            var phoneNumber = exNumber_tf.text
            phoneNumber = "+" + phoneNumber!
            phoneNumber = phoneNumber! + number_tf.text!
            phoneNumber = phoneNumber!.replacingOccurrences(of: " ", with: "")
            if phoneNumber?.count != 12 {
                message = "Enter a valid phone number"
                flag = false
            }
        }
        
        if email_tf.text == "" {
            message = "Email field missing"
            flag = false
        }
        if password_tf.text == "" {
            message = "Passqord field missing"
            flag = false
        }
        if confirm_password_tf.text == "" {
            message = "Confirm password field missing"
            flag = false
        }
        if birthdaySelected == "" {
            message = "Select a birthdate"
            flag = false
        }
        if address == "" {
            message = "Select address"
            flag = false
        }
        if password_tf.text != confirm_password_tf.text {
            message = "Make sure if everything its ok"
            flag = false
        }
        
        if !male_btn.isSelected , !female_btn.isSelected {
            message = "Select a gender"
            flag = false
        }
        
        if !flag {Alert.showBasicAlert(on: self, with: "Missing field", message: message)}
        return flag
    }
    
    //MARK: - Seteo visual
    func setVisualComponents(){
        image_logo.layer.cornerRadius = 50
        image_logo.clipsToBounds = true
        
        personal_information_conteiner.layer.cornerRadius = 30
        personal_information_conteiner.clipsToBounds = true
        
        access_information_conteiner.layer.cornerRadius = 30
        access_information_conteiner.clipsToBounds = true
        
        create_account_btn.backgroundColor = .colorPrimary
        create_account_btn.layer.cornerRadius = 15
        create_account_btn.clipsToBounds = true
    }
    
    func createBirthdayPicker() {
        
        birthdayPicker = UIDatePicker()
        birthdayPicker?.datePickerMode = .date
        
        birthday_tf.inputView = birthdayPicker
    }
    
    func createToolbar() {
        let toolBarBirthday = UIToolbar()
        toolBarBirthday.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButtonBirthday = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreateAccount.doneAccionBirthday))
        
        toolBarBirthday.setItems([flexSpace,doneButtonBirthday], animated: false)
        toolBarBirthday.isUserInteractionEnabled = true
        
        birthday_tf.inputAccessoryView = toolBarBirthday
    }
    
    
    @objc func doneAccionBirthday() {
        view.endEditing(true)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MMMM-yyyy"
        let date = dateFormat.string(from: birthdayPicker!.date)
        birthday_tf.text = date.replacingOccurrences(of: "-", with: " ")
        dateFormat.dateFormat = "yyyy-MM-dd"
        birthdaySelected = dateFormat.string(from: birthdayPicker!.date)
    }
    
    @objc func tapGestureDone(){
        view.endEditing(true)
    }
}

extension CreateAccount: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        bottonConstraint.constant = 320
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        bottonConstraint.constant = 20
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name_tf {
            textField.resignFirstResponder()
            family_name_tf.becomeFirstResponder()
        }else if textField == family_name_tf{
            textField.resignFirstResponder()
        }
        
        if textField == email_tf {
            textField.resignFirstResponder()
            password_tf.becomeFirstResponder()
        }else if textField == password_tf{
            textField.resignFirstResponder()
            confirm_password_tf.becomeFirstResponder()
        } else if textField == confirm_password_tf {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}



