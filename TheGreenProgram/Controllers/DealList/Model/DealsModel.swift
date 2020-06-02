//
//  DealsModel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/20/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

class DealsModel{
    var originalData: [Deal] = []
    var deals:[Deal] = []
    
    let url = "https://thegreenmarket.tk/api/deals"
    var dealsParams: [String:String] = ["fromItem":"0","itemQuantity":"0","filterName":""]
    
    func appendDeal(deal:Deal){
        self.deals.append(deal)
    }
    
    func cleanData(){
        deals = []
    }
    
    func getDealsCount() -> Int {
        return self.deals.count
    }
    
    func setDealsParams(fromItem: String,itemsQuantity: String,filterName:String){
        dealsParams["fromItem"] = fromItem
        dealsParams["itemsQuantity"] = itemsQuantity
        dealsParams["filterName"] = filterName
    }
}
