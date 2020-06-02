//
//  HexColors.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 1/15/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation

import UIKit

extension UIColor{
    
    static let primaryDarkTextColor = UIColor().colorFromHex("#000000")
    static let primaryTextColor = UIColor().colorFromHex("#ffffff")
    static let colorPrimary = UIColor().colorFromHex("#2E7D32")
    static let colorPrimaryDark = UIColor().colorFromHex("#000000")
    static let colorAccent = UIColor().colorFromHex("#1565c0")
    static let colorBackground = UIColor().colorFromHex("#F5F5F5")
    static let colorRed = UIColor().colorFromHex("#DC3645")
    
    func colorFromHex(_ hex : String)-> UIColor{
        
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#"){
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6{
            return UIColor.black
        }
        
        var rgb : UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                            blue: CGFloat(rgb & 0x0000FF) / 255.0,
                            alpha: 1.0)
        
    }
}
