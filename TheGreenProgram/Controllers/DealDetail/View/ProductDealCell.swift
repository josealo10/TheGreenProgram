//
//  ProductDealCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/22/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class ProductDealCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var unitMeasurementLabel: UILabel!
    @IBOutlet weak var priceWithNoDealLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var minusBTN: UIButton!
    @IBOutlet weak var plusBTN: UIButton!
    
    var updateView: (() -> Void)?
    var fullAmmount: (() -> Void)?
    
    var product:Product?
    var dealType: String?
    var base_amount: Int?
    var additional_product:Int?
    var quantity_products: Int?
    var percentage_discount_at_quantity: Int?
    
    func setView(product: Product){
        
        self.product = product
        
        nameLabel.text = product.name ?? ""
        priceWithNoDealLabel.text = ""
        priceLabel.text = (product.type_currency ?? "") + String((product.net_price)!)
        unitMeasurementLabel.text = product.unit_measurement ?? ""
        quantityLabel.text = String(product.quantity!)
        
        if dealType == "cashDiscount" || dealType == "percentageDiscount"{
            let n = product.price!
            let str = (product.type_currency ?? "") + " " + String(n)
            let attributeString =  NSMutableAttributedString(string: str)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            priceWithNoDealLabel.attributedText = attributeString
            priceWithNoDealLabel.textColor = .lightGray
        }
        
        plusBTN.backgroundColor = .colorPrimary
        plusBTN.tintColor = .primaryTextColor
        
        minusBTN.backgroundColor = .colorPrimary
        minusBTN.tintColor = .primaryTextColor
        
        plusBTN.layer.cornerRadius = 11
        minusBTN.layer.cornerRadius = 11
        
        if product.quantity_store_product == 0 {
            plusBTN.backgroundColor = .darkGray
            minusBTN.backgroundColor = .darkGray
            
            nameLabel.textColor = .darkGray
            priceLabel.textColor = .darkGray
            unitMeasurementLabel.textColor = .darkGray
            quantityLabel.textColor = .darkGray
            
            plusBTN.isEnabled = false
            minusBTN.isEnabled = false
        }
    }
    
    func calculateQuantityProducts()->Int{
        if product!.quantity! == 0 {return 0}
        if dealType ==  "additionalProduct"{
            return product!.quantity! * (base_amount! + additional_product!)
        }
        return product!.quantity!
    }
    
    
    @IBAction func minus(_ sender: Any) {
        if product!.quantity! != 0{
            product?.quantity! -= 1
            setView(product: product!)
        }
        updateView!()
    }
    
    @IBAction func plus(_ sender: Any) {
        var quantity = 0
        if dealType == "additionalProduct"{
            quantity = calculateQuantityProducts() + base_amount! + additional_product!
        }
        else{
            quantity = product!.quantity!
        }
        
        if (product?.quantity_store_product)! >= quantity{
            product?.quantity! += 1
            setView(product: product!)
        }
        else{
            fullAmmount!()
        }
        
        updateView!()
    }
    
}
