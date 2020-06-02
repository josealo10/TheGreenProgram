//
//  Order.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/11/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

struct orderStatusNotes:Decodable{
    var note:String?
    var date:String?
    var status: String?
}

class Order: Decodable{
    let id:Int?
    let date:String?
    let customer_id:Int?
    let customer_name:String?
    let customer_phone_number:String?
    let store_id:Int?
    let store_name:String?
    let price:Double?
    let shipping_price:Double?
    let shipping_address_longitude:Double?
    let shipping_address_latitude:Double?
    let shipping_address_details:String?
    let payment_method:String?
    let loyalty_points_earned:Int?
    let loyalty_points_used:Int?
    let status:String?
    let note:String?
    let products:[Product]?
    let deals:[Deal]?
    let orderStatusNotes:[orderStatusNotes]?
}
