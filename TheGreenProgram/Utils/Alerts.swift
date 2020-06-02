//
//  Alerts.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/17/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    
    static func showBasicAlert(on vc: UIViewController, with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async { vc.present(alert, animated: true) }
    }
    
    static func showDecitionAlert (on vc: UIViewController, with title: String, message: String, acceptHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void){
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
            cancelHandler()
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
            acceptHandler()
        }))
        
        
        
        DispatchQueue.main.async { vc.present(alert, animated: true) }
    }
    
    static func showDecitionAlert (on vc: UIViewController, with title: String, message: String, acceptTitle:String, acceptHandler: @escaping () -> Void, cancelTitle:String, cancelHandler: @escaping () -> Void){
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: acceptTitle, style: UIAlertAction.Style.default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
            acceptHandler()
        }))
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.destructive, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
            cancelHandler()
        }))
        
        DispatchQueue.main.async { vc.present(alert, animated: true) }
    }
    
}
