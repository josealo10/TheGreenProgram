//
//  DealsCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/20/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class DealsCell: UITableViewCell {

    
    @IBOutlet weak var imageCell: UIImageView!
    
    @IBOutlet weak var titleCell: UILabel!
    
    @IBOutlet weak var descriptionCell: UILabel!
    
    @IBOutlet weak var priceCell: UILabel!
    
    @IBOutlet weak var backgroundCardView: UIView!
    
    @IBOutlet weak var backView: UIView!
    func setView(deal:Deal){
        let url = URL(string: deal.image_url!)
        imageCell.sd_setImage(with: url, completed: nil)
        titleCell.text = deal.name
        descriptionCell.text = deal.description
        //priceCell.text = String(deal.price!)
        backView.backgroundColor = .colorBackground
        backgroundCardView.backgroundColor = UIColor.white
        backgroundCardView.layer.cornerRadius = 10.0
        backgroundCardView.clipsToBounds = true
        
        backgroundCardView.layer.shadowColor = UIColor.lightGray.cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
    }

}
