//
//  MyAccountCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/25/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

class MyAccountCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let valueTextFiel: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chagePasswordLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        label.setTitleColor(.systemBlue, for: .normal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var genderPiker: UIPickerView?
    let genderData = ["Male","Female"]
    var birthdayPicker: UIDatePicker?
    var birthdaySelected:String?
    var phoneNumber: String?
    var showMap: (() -> Void)?
    var changePassword: (() -> Void)?
    var changePhoneNumber: ((_ phone:String) -> Void)?
    var changeBirthdate: ((_ birthDate:String)-> Void)?
    
    func configureInformation(description:String, value:String){
        
        descriptionLabel.text = description
        valueLabel.text = value
        
        addSubview(descriptionLabel)
        descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: descriptionLabel.widthAnchor).isActive = true
        
        addSubview(valueLabel)
        valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        valueLabel.leftAnchor.constraint(equalTo: descriptionLabel.rightAnchor,constant: 16).isActive = true
        
    }
    
    func configureSegurity(description:String){
        chagePasswordLabel.setTitle(description, for: .normal)
        
        addSubview(chagePasswordLabel)
        chagePasswordLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        chagePasswordLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        chagePasswordLabel.addTarget(self, action: #selector(showChangePasswordView), for: .touchDown)
    }
    
    func configureEditView(type:String, description: String, value: String){
        descriptionLabel.text = description
        valueTextFiel.text = value
        
        configureEditTextFiel(type:type)
        
        addSubview(descriptionLabel)
        descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: descriptionLabel.widthAnchor).isActive = true
        
        addSubview(valueTextFiel)
        valueTextFiel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        valueTextFiel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        valueTextFiel.leftAnchor.constraint(equalTo: descriptionLabel.rightAnchor,constant: 16).isActive = true
    }
    
    func configureEditTextFiel(type:String){
        switch type {
        case "Name": break
        case "Surname": break
        case "Gender":
            createGenderPickerView()
            createGenderToolbar()
        case "Birthdate":
            createBirthdayPicker()
            createBirthdateToolbar()
        case "phone_number":
            valueTextFiel.keyboardType = .numberPad
            
        case "Address":
            //valueTextFiel.addTarget(self, action: #selector(showMapView), for: .touchDown)
            valueTextFiel.delegate = self
        default:
            break
        }
    }
    func createGenderPickerView(){
        genderPiker = UIPickerView()
        genderPiker?.delegate = self
        genderPiker?.dataSource = self
        valueTextFiel.inputView = genderPiker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        genderData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueTextFiel.text = genderData[row]
    }
    func createGenderToolbar() {
        let toolBarGender = UIToolbar()
        toolBarGender.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAccionGender))
        toolBarGender.setItems([flexSpace,doneButton], animated: false)
        toolBarGender.isUserInteractionEnabled = true
        valueTextFiel.inputAccessoryView = toolBarGender
    }
    
    func createBirthdayPicker() {
        birthdayPicker = UIDatePicker()
        birthdayPicker?.datePickerMode = .date
        valueTextFiel.inputView = birthdayPicker
    }
    
    func createBirthdateToolbar() {
        let toolBarBirthday = UIToolbar()
        toolBarBirthday.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButtonBirthday = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAccionBirthday))
        
        toolBarBirthday.setItems([flexSpace,doneButtonBirthday], animated: false)
        toolBarBirthday.isUserInteractionEnabled = true
        
        valueTextFiel.inputAccessoryView = toolBarBirthday
    }
    
    @objc func doneAccionGender(){
        endEditing(true)
    }
    
    @objc func doneAccionBirthday() {
        endEditing(true)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MMMM-yyyy"
        let date = dateFormat.string(from: birthdayPicker!.date)
        valueTextFiel.text = date.replacingOccurrences(of: "-", with: " ")
        dateFormat.dateFormat = "yyyy-MM-dd"
        birthdaySelected = dateFormat.string(from: birthdayPicker!.date)
        changeBirthdate!(birthdaySelected!)
    }
    
    @objc func showMapView(){
        (showMap ?? {})()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (showMap ?? {})()
    }
    @objc func showChangePasswordView(){
        (changePassword ?? {})()
    }
}
