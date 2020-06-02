//
//  ChangePasswordCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/26/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class ChangePasswordCell: UITableViewCell {
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let valueTextFiel: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.placeholder = "Required"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let changePasswordLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        label.setTitleColor(.systemBlue, for: .normal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var changePassword:(()->Void)?
    
    func configureTextFields(description:String){
        descriptionLabel.text = description
        
        addSubview(descriptionLabel)
        descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        
        addSubview(valueTextFiel)
        valueTextFiel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        valueTextFiel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
    }
    
    func configureChangeButton(value:String){
        changePasswordLabel.setTitle(value,for: .normal)
        
        addSubview(changePasswordLabel)
        changePasswordLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        changePasswordLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        changePasswordLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        changePasswordLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        changePasswordLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        changePasswordLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        changePasswordLabel.addTarget(self, action: #selector(changePasswordMethod), for: .touchDown)
    }
    
    @objc func changePasswordMethod(){
        (changePassword ?? {})()
    }

}
