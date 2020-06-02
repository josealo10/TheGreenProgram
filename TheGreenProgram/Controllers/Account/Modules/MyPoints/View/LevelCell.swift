//
//  LevelCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/3/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class LevelCell: UICollectionViewCell {
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var reward1: UILabel!
    @IBOutlet weak var reward2: UILabel!
    @IBOutlet weak var reward3: UILabel!
    @IBOutlet weak var reachLevelMessage: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var crownIcon: UIImageView!
    
    var seeMore:(()->Void)?
    
    func setView(level:LoyaltyLevel){
        background.backgroundColor = .colorBackground
        container.backgroundColor = UIColor.white
        container.layer.cornerRadius = 10.0
        container.layer.masksToBounds = false
        
        container.layer.shadowColor = UIColor.lightGray.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 0)
        container.layer.shadowOpacity = 0.8
        
        
        pointsLabel.text = ""
        if Profile.loyaltyLevelID != level.id{
            self.sendSubviewToBack(slider)
            self.sendSubviewToBack(pointsLabel)
            
            let levelPts:String = String(Profile.current_points)
            let levelName:String = level.name ?? "next"
            
            reachLevelMessage.text = "Get " + levelPts + " points to reach " + levelName + " level"
            
            slider.maximumValue = 10
            slider.minimumValue = 0
            slider.setValue(0, animated: false)
        }else{
            slider.minimumValue = Float(level.required_points!)
            if (level.nextLevel) != nil {
                slider.maximumValue = Float((level.nextLevel?.required_points)!)
                pointsLabel.text = String(Profile.current_points) + "/" + String((level.nextLevel?.required_points)!)
                
                let levelPts:String = String((level.nextLevel?.required_points)!)
                let levelName:String = level.nextLevel?.name ?? "next"
                
                reachLevelMessage.text = "Get " + levelPts + " points to reach " + levelName + " level"
            }else{
                slider.maximumValue = Float(Profile.current_points)
                pointsLabel.text = String(Profile.current_points)
            }
            slider.minimumTrackTintColor = UIColor().colorFromHex(level.color ?? "ffffff")
            slider.setValue(Float(Profile.current_points), animated: true)
            
        }
        
        reward1.text = ""
        reward2.text = ""
        reward3.text = ""
        
        levelLabel.text = level.name
        if !(level.benefits?.isEmpty ?? true){
            for n in 0...level.benefits!.count - 1{
                if n == 0{
                    reward1.text = "• " + (level.benefits?[n] ?? "")
                }
                if n == 1{
                    reward2.text = "• " + (level.benefits?[n] ?? "")
                }
                if n == 2{
                    reward3.text = "• " + (level.benefits?[n] ?? "")
                    break
                }
        }
        }
        crownIcon.backgroundColor = UIColor().colorFromHex(level.color ?? "000000")
        
    }
    
    @IBAction func seeMore(_ sender: Any) {
        seeMore!()
    }
    
    
}
