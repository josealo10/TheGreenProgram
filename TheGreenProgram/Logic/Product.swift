//
//  Product.swift
//  TheGreenProgram
//
//  Created by Jose Alonso Alfaro Perez on 12/2/19.
//  Copyright © 2019 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

class Product:Decodable{
    var store_product_id: Int?
    var images: [String]?
    var name: String?
    var description: String?
    var price: Double?
    var quantity: Int?
    var unit_measurement: String?
    var type_currency: String?
    var quantity_shopping_cart: Int?
    var quantity_store_product:Int?
    var net_price:Double?
    var image_url:String?
    
    
    var product_id:Int?
    var product_name:String?
    var product_image_url:String?
    var product_price:Double?
    var product_unit_measurement:String?
    //var type_currency:String?
    var products_quantity:Int?
    var deals_applied:Int?
    var total_deal_price_applied:Double?
}
