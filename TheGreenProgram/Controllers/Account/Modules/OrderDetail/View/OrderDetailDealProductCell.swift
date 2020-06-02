//
//  OrderDetailDealProductCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 6/1/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

class OrderDetailDealProductCell:UITableViewCell{
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
    @IBOutlet weak var typeCurrency: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    
    
    func setView(product:Product) {
        let url = URL(string: product.product_image_url ?? "" )
        productImage.sd_setImage(with: url, placeholderImage:UIImage(named: "no_image"), completed: nil)
        
        name.text = product.product_name
        unitPrice.text = product.type_currency ?? "" + String(product.product_price!)
        typeCurrency.text = product.product_unit_measurement
        quantity.text = String(product.deals_applied ?? 1)
        totalPrice.text = String(product.total_deal_price_applied ?? 0 )
    }
}