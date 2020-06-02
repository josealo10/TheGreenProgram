//
//  CartModal.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/14/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

class CartModel{
    var storeList: [Store] = []
    var data: [[Any]] = []
    let url = "https://thegreenmarket.tk/api/shopping-cart"
    let orderUrl = "https://thegreenmarket.tk/api/orders"
}
