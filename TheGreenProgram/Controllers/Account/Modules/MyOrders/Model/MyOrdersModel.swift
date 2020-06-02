//
//  MyOrdersModel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/11/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
class MyOrdersModel{
    var orders:[Order]!
    var all:[Order] = []
    var awaitting:[Order] = []
    var cancelled:[Order] = []
    var confirmed:[Order] = []
    var shipping:[Order] = []
    var delivered:[Order] = []
    let url:String = "https://thegreenmarket.tk/api/orders"
    var params:[String:String] = ["fromItem":"0","itemsQuantity": "50","status":""]
    
    init() {
        orders = all
    }
    
    func setParams(fromItem:String, itemsQuantity:String, status:String){
        params["fromItem"] = fromItem
        params["itemsQuantity"] = itemsQuantity
        params["status"] = status
    }
}
