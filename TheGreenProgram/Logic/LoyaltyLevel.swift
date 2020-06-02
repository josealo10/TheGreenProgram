//
//  LoyaltyLevel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 4/12/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

class LoyaltyLevel:Decodable {
    let id:Int?
    let name:String?
    let required_points:Int?
    let bonus_points_percentage:Int?
    let color:String?
    let benefits:[String]?
    var nextLevel:LoyaltyLevel?
}
