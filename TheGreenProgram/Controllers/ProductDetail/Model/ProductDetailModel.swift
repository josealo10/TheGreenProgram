//
//  ProductDetailModel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/29/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
class ProductDetailModel{
    var product:Product!
    var deal_id: Int = -1
    var dealMode:Bool = false
    var editMode:Bool = false
    var dealType:String = ""
    var cash_discount: Double = 0
    var percentage_discount: Double = 0
    var base_amount: Int = 0
    var additional_product:Int = 0
    var quantity_products:Int = 0
    var percentage_discount_at_quantity:Int = 0
    
    var url:String = "https://thegreenmarket.tk/api/shopping-cart"
    
    func setFirstValues(){
        if !editMode{
            if dealMode{
                if product.quantity == 0{
                    product.quantity = 1
                }
            }else{
                product.quantity = 1
            }
        }else{
            product.quantity = product.quantity_shopping_cart
        }
    }
}
