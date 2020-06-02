//
//  Store.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/20/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

class Store:Decodable{
    var id:Int?
    var name:String?
    var phone:String?
    var description: String?
    var shipping_price:Double? = 1500
    var products: [Product]?
    var deals:[Deal]?
}
