//
//  SettingsSection.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit

protocol SectionType: CustomStringConvertible {
    var image:UIImage { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case profile
    case myOptions
    case logout
    
    var description: String {
        switch self {
        case .profile: return "profile"
        case .myOptions: return "My options"
        case .logout: return "Logout"
        }
    }
}

enum profile: Int, CaseIterable, SectionType {
    case profile
    
    var description: String {
        switch self {
        case .profile: return "profile"
        }
    }
    
    var image: UIImage{
        return UIImage(named: "logo")!
    }
    
}

enum myOptions: Int, CaseIterable, SectionType {
    case myPoints
    case myOrders
    case wish
    
    
    var description: String {
        switch self {
        case .myPoints: return "My points"
        case .myOrders: return "My orders"
        case .wish: return "Wish list"
        }
    }
    
    var image: UIImage {
        switch self {
        case .myPoints: if #available(iOS 13.0, *) {
            return UIImage(named: "crowns")!
        } else {
            // Fallback on earlier versions
            return UIImage()
            }
        case .myOrders: if #available(iOS 13.0, *) {
            return UIImage(named: "order")!
        } else {
            // Fallback on earlier versions
            return UIImage()
            }
        case .wish: if #available(iOS 13.0, *) {
            return UIImage(systemName: "heart.fill")!
        } else {
            // Fallback on earlier versions
            return UIImage()
            }
        }
    }
}

enum logOut: Int, CaseIterable, SectionType {
    case logout
    
    
    var description: String {
        switch self {
        case .logout: return "Logout"
        }
    }
    
    var image: UIImage {
        switch self {
        case .logout: if #available(iOS 13.0, *) {
            return UIImage(systemName: "arrowshape.turn.up.left")!
        } else {
            // Fallback on earlier versions
            return UIImage()
            }
        }
    }
}
