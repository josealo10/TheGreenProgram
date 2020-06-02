//
//  PaymentMethod.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/7/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

struct paymentMethod{
    let image:UIImage
    var name:String
    var value:String
    var isSelected:Bool
    
    init(image:UIImage, name:String, isSelected:Bool, value:String) {
        self.image = image
        self.name = name
        self.isSelected = isSelected
        self.value = value
    }
}

class PaymentMethod: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var paymentMethods:[paymentMethod]?
    
    var changePaymentMethod: ((_ paymentMethods:[paymentMethod])->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .colorBackground
        view.backgroundColor = .colorBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    func configureNavigationBar(){
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let image = UIImageView()
        image.image = paymentMethods?[indexPath.row].image
        image.translatesAutoresizingMaskIntoConstraints = false
        if paymentMethods?[indexPath.row].name == "Loyalty Points"{
            //image.backgroundColor = UIColor().colorFromHex("#FAD63C")
        }
        
        cell.addSubview(image)
        image.heightAnchor.constraint(equalToConstant: 40).isActive = true
        image.widthAnchor.constraint(equalToConstant: 40).isActive = true
        image.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 10).isActive = true
        
        let name = UILabel()
        name.text = paymentMethods?[indexPath.row].name
        name.translatesAutoresizingMaskIntoConstraints = false
        
        cell.addSubview(name)
        name.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
        name.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
        
        let check = UIImageView()
        check.image = UIImage(systemName: "checkmark")
        check.tintColor = .white
        if paymentMethods?[indexPath.row].isSelected ?? true{
            check.tintColor = .link
        }
        check.translatesAutoresizingMaskIntoConstraints = false
        
        cell.addSubview(check)
        check.heightAnchor.constraint(equalToConstant: 20).isActive = true
        check.widthAnchor.constraint(equalToConstant: 30).isActive = true
        check.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -10).isActive = true
        check.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .colorBackground
        
        let label = UILabel()
        label.text = "Choose Payment Method"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        label.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        paymentMethods = [
            paymentMethod(image: UIImage(named: "bill")!,name: "Cash",isSelected: false, value: "Cash"),
            paymentMethod(image: UIImage(named: "crowns")!,name: "Loyalty Points",isSelected: false, value: "loyaltyPoints")
        ]
        paymentMethods?[indexPath.row].isSelected = true
        
        changePaymentMethod!(paymentMethods!)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    

}
