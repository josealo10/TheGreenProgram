//
//  MyAccountModel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/25/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

class MyAccountModel{
    var url:String = "https://thegreenmarket.tk/api/accounts"
    let sections = [("Information","Information"),("Security","Security")]
    
    let  securityOption = "Change password"
    
    var information:[(String,String)]!
    
    
    let editSections = [("Information","Information")]
    
    var editInformation :[(String,String,String)]!
    
    
    func refreshData(){
        information = [
            ("Name",Profile.name),
            ("Surname",Profile.surname),
            ("Gender",Profile.gender),
            ("Birthdate",Profile.birthday),
            ("Phone number",Profile.phone_number),
            ("Address",Profile.address),
            ("Email",Profile.email),
        ]
        
        editInformation = [
            ("Name","Name",Profile.name),
            ("Surname","Surname",Profile.surname),
            ("Gender","Gender",Profile.gender),
            ("Birthdate","Birthdate",Profile.birthday),
            ("phone_number","Phone number",Profile.phone_number),
            ("Address","Address",Profile.address)
        ]
    }
    
}
