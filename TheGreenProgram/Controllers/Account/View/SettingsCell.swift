//
//  SettingsCell.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    
    var descrip: String?
    var img:UIImage?
    
    
    var sectionType: SectionType?
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let profileImageView: UILabel = {
        let iv = UILabel()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.colorPrimary
        var str = ""
        var name = Profile.name
        name = name.replacingOccurrences(of: " ", with: "")
        for ch in name{
            str = str + String(ch)
            break
        }
        var surname = Profile.surname
        surname = surname.replacingOccurrences(of: " ", with: "")
        for ch in surname{
            str = str + String(ch)
            break
        }
        
        iv.text = str.uppercased()
        iv.font = UIFont.boldSystemFont(ofSize: 30.0)
        iv.textColor = .white
        iv.textAlignment = .center
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = Profile.name
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = Profile.email
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let logoutLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView(){
        
        switch sectionType {
        case is profile:
            editProfileCell()
        case is logOut:
            editLogoutCell()
        default:
            editComonCell()
        }
    }
    
    func editProfileCell(){
        let profileImageDimension: CGFloat = 60
        
        addSubview(profileImageView)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
        profileImageView.layer.cornerRadius = profileImageDimension / 2
        
        addSubview(usernameLabel)
        usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -10).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
        
        addSubview(emailLabel)
        emailLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 10).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
        
        addSubview(rightButton)
        rightButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        rightButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    func editLogoutCell(){
        logoutLabel.text = sectionType?.description
        
        addSubview(logoutLabel)
        logoutLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoutLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func editComonCell(){
        let image = UIImageView()
        image.image = sectionType?.image
        image.tintColor = .red
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.heightAnchor.constraint(equalToConstant: 25).isActive = true
        image.widthAnchor.constraint(equalToConstant: 25).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let text = UILabel()
        text.text = sectionType?.description
        text.translatesAutoresizingMaskIntoConstraints = false
        addSubview(text)
        text.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
        text.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        addSubview(rightButton)
        rightButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        rightButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
}

