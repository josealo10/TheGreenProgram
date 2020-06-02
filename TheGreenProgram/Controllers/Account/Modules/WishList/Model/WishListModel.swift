//
//  WishListModel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 6/1/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

class WishListModel{
    var products : [Product] = []
    var originalData : [Product] = []
    
    var url: String = "https://thegreenmarket.tk/api/wish-list"
    var urlHeaderPath:[String] = []
    var urlParams:[String:String] = [:]
    
    func getProductsCount() -> Int{
        return products.count
    }
    
    func setURLHeaderPath(urlHeaderPath:[String]){
        self.urlHeaderPath = urlHeaderPath
    }
    
    func setProductsParams(fromItem: String,itemsQuantity: String,filterName:String){
        urlParams["fromItem"] = fromItem
        urlParams["itemsQuantity"] = itemsQuantity
        urlParams["filterName"] = filterName
    }
    
    func setProducts(products:[Product]){
        self.products = products
    }
    
    func cleanData(){
        products = []
    }
}
