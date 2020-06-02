//
//  WishListCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 6/1/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
//Created by Real Life Swift on 22/12/2018

import UIKit

class WishListCell: UICollectionViewCell {
  

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descrip: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var soldOut: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    
    
    func setView(product:Product){
        
        let url = URL(string: product.images?[0] ?? "")
        self.image.sd_setImage(with: url, placeholderImage:UIImage(named: "no_image"), completed: nil)
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        
        name.text = product.name
        descrip.text = product.description
        price.text = String(product.price!) + " " + (product.type_currency ?? "")
        
        backgroundCardView.backgroundColor = UIColor.white
        backgroundCardView.layer.cornerRadius = 10.0
        backgroundCardView.layer.masksToBounds = false
        
        backgroundCardView.layer.shadowColor = UIColor.lightGray.cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
        
        if product.quantity == 0{
            backgroundCardView.backgroundColor = .colorBackground
            soldOut.text = "  Sold out  "
            soldOut.backgroundColor = .colorBackground
            soldOut.textColor = .red
            soldOut.layer.cornerRadius = 5
            soldOut.clipsToBounds = true
        }
        else{
            soldOut.text = ""
        }
    }
    
}
