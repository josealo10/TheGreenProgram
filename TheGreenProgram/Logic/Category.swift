//
//  Categorie.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/16/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

class Category:Decodable{
    let has_subCategories: Bool?
    let id: Int?
    let image_url: String?
    let name: String?
    let products: [Product]?
    
    init(has_subCategories:Bool, id: Int, image: String, name: String, products: [Product]) {
        self.has_subCategories = has_subCategories
        self.id = id
        self.image_url = image
        self.name = name
        self.products = products
    }
    
}

