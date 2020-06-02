//
//  StoreModel.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/31/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class StoreModal: UIViewController {
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var descriptionLabel:UILabel!
    
    @IBOutlet weak var phoneBTN: UIButton!
    @IBOutlet weak var imageContainer:UIView!
    @IBOutlet weak var storeImage: UIImageView!
    
    var tittle = ""
    var des = ""
    var phone = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageContainer.layer.cornerRadius = 27.5
        nameLabel.text = tittle
        descriptionLabel.text = des
        phoneBTN.setTitle(phone, for: .normal)
        storeImage.backgroundColor = .colorPrimary
    }
    
    @IBAction func callPhone(_ sender: Any) {
        phone.makeACall()
    }
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension String {

    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }

    func isValid(regex: RegularExpressions) -> Bool { return isValid(regex: regex.rawValue) }
    func isValid(regex: String) -> Bool { return range(of: regex, options: .regularExpression) != nil }

    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }

    func makeACall() {
        guard   isValid(regex: .phone),
                let url = URL(string: "tel://\(self.onlyDigits())"),
                UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
