//
//  CartCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/14/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import SDWebImage

class CartCell: UITableViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    
    @IBOutlet weak var titleCell: UILabel!
    
    @IBOutlet weak var unityprice: UILabel!
    @IBOutlet weak var priceCell: UILabel!
    @IBOutlet weak var plusBTN: UIButton!
    @IBOutlet weak var minusBTN: UIButton!
    @IBOutlet weak var quiantityLabel: UILabel!
    
    var product: Product!
    
    var updateProduct: (() -> Void)?
    
    
    func setView(product: Product){
        
        self.product = product
        
        let url = URL(string: product.images?[0] ?? "" )
        imageCell.sd_setImage(with: url, placeholderImage:UIImage(named: "no_image"), completed: nil)
        
        titleCell.text = String((product.name ?? ""))
        
        let n1:Double = (product.price ?? 0)
        let n2:Double = Double(product.quantity_shopping_cart ?? 0)
        let r:Double =  n1 * n2
        priceCell.text = (product.type_currency ?? "") + " " + String(r)
        
        unityprice.text = (product.type_currency ?? "") + " " + String(product.price ?? 0)
        
        quiantityLabel.text = String(product.quantity_shopping_cart ?? 0)
        
        plusBTN.backgroundColor = .colorPrimary
        plusBTN.tintColor = .primaryTextColor
        minusBTN.backgroundColor = .colorPrimary
        minusBTN.tintColor = .primaryTextColor
        plusBTN.layer.cornerRadius = 11
        minusBTN.layer.cornerRadius = 11
    }
    
    @IBAction func plusBTN(_ sender: Any) {
        product.quantity_shopping_cart! += 1
        updateProduct!()
        
    }
    
    @IBAction func minusBTN(_ sender: Any) {
        product.quantity_shopping_cart! -= 1
        updateProduct!()
    }
}
