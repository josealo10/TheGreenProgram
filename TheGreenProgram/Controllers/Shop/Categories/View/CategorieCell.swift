//
//  CategorieCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/10/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import SDWebImage
class CategorieCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    
    func setView(image:String, name:String){
        let url = URL(string: image)
        self.image.sd_setImage(with: url, placeholderImage: UIImage(named: "no_image"),completed: nil)
        nameLabel.text = name
        
        backView.backgroundColor = .colorBackground
        containerView.backgroundColor = UIColor.white
        //containerView.layer.cornerRadius = 10.0
        //containerView.layer.masksToBounds = false
        
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.8
    }
}
