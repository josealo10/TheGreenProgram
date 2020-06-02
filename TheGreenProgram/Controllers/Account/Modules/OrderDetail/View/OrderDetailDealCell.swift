//
//  OrderDetailDealCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 6/1/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

class OrderDetailDealCell: UITableViewCell{
    @IBOutlet weak var dealName: UILabel!
    @IBOutlet weak var dealImage: UIImageView!
    @IBOutlet weak var priceWithOutDeal: UILabel!
    @IBOutlet weak var priceWithDeal: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    let sizeCell = 130
    
    var deal:Deal?
    
    func setView(deal:Deal){
        self.deal = deal
        dealName.text = deal.name
        let url = URL(string: deal.image_url ?? "" )
        dealImage.sd_setImage(with: url, placeholderImage:UIImage(named: "no_image"), completed: nil)
        
        let n = calculateFinalPriceWithNoDeal()
        let str = "Final price with no deal CRC " + String(n)
        let attributeString =  NSMutableAttributedString(string: str)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        priceWithOutDeal.attributedText = attributeString
        priceWithOutDeal.textColor = .lightGray
        
        priceWithDeal.text =  "Final price with deal CRC " + String(calculateFinalPriceWithDeal())
        
        
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(sizeCell * (deal.products?.count ?? 0))).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func calculateFinalPriceWithNoDeal()->Double{
        var n: Double = 0
        for product in deal?.products ?? []{
            n += (product.product_price ?? 0) * Double(product.products_quantity ?? 0)
        }
        return n
    }
    
    func calculateFinalPriceWithDeal() -> Double{
        var n : Double = 0
        for product in deal?.products ?? []{
            n += (product.total_deal_price_applied ?? 0) * Double(product.deals_applied ?? 0)
        }
        return n
    }
}

extension OrderDetailDealCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deal?.products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealProductOrder") as! OrderDetailDealProductCell
        cell.setView(product: (deal?.products?[indexPath.row])!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(sizeCell)
    }
}
