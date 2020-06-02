//
//  CartDealCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/31/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import SDWebImage

class CartDealCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var finalPrice: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setView(name:String,finalPrice:Double, image:String, typeCurrency:String, description:String){
        let url = URL(string: image )
        img.sd_setImage(with: url, placeholderImage:UIImage(named: "no_image"), completed: nil)
        self.name.text = name
        self.finalPrice.text = typeCurrency + " " + String(finalPrice)
        self.descriptionLabel.text = description
    }
}
