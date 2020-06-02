//
//  HomeModel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 4/6/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
class HomeModel{
    let urlDeals = "https://thegreenmarket.tk/api/home"
    
    var deals:[Deal] = []
    var mostSoldProducts:[Product] = []
    var lastedAddedProducts:[Product] = []
}
