//
//  Deal.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/20/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

class Deal: Decodable{
    var id: Int?
    var image_url: String?
    var description: String?
    var name: String?
    var end_date:String?
    var type_currency:String?
    var total_price:Double?
    var products: [Product]?
    
    var type: String?
    var cash_discount: Double?
    var percentage_discount: Double?
    var base_amount: Int?
    var additional_product:Int?
    var quantity_products: Int?
    var percentage_discount_at_quantity: Int?
    
}
