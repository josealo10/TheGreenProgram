//
//  ChangePassword.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/26/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class ChangePassword: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var model = ChangePasswordModel()
    
    var oldPasswordTF: UITextField?
    var newPasswordTF: UITextField?
    var confirmTF: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorBackground
        tableView.backgroundColor = .colorBackground
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func tapGestureDone(){
        view.endEditing(true)
    }
    
    func changePassword(){
        
    }
}

//MARK:- Extensions
extension ChangePassword: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChangePasswordCell()
        if indexPath.section == 0{
            
            cell.configureTextFields(description: model.sections[indexPath.section][indexPath.row].1)
            
            switch model.sections[indexPath.section][indexPath.row].0 {
            case "oldPassword": oldPasswordTF = cell.valueTextFiel
            case "newPassword": newPasswordTF = cell.valueTextFiel
            case "confirm": confirmTF = cell.valueTextFiel
            default:
                break
            }
        }
        else{
            cell.configureChangeButton(value: model.sections[indexPath.section][indexPath.row].1)
            cell.changePassword = {self.changePassword()}
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        if section == 0{
            let title = UILabel()
            title.font = UIFont.systemFont(ofSize: 16)
            title.textColor = .lightGray
            title.numberOfLines = 0
            title.backgroundColor = .colorBackground
            title.text = "The password must contain at leat 8 characters long, also it must contain numbers"
            
            view.addSubview(title)
            title.translatesAutoresizingMaskIntoConstraints = false
            title.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
            title.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 40}
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK:- Table display configuration
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

            if (cell.responds(to: #selector(getter: UIView.tintColor))){
                if tableView == self.tableView {
                    let cornerRadius: CGFloat = 12.0
                    cell.backgroundColor = .clear
                    let layer: CAShapeLayer = CAShapeLayer()
                    let path: CGMutablePath = CGMutablePath()
                    let bounds: CGRect = cell.bounds
                    //bounds.insetBy(dx: 25.0, dy: 0.0)
                    var addLine: Bool = false

                    if indexPath.row == 0 && indexPath.row == ( tableView.numberOfRows(inSection: indexPath.section) - 1) {
                        path.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)

                    } else if indexPath.row == 0 {
                        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
                        path.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
                        path.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
                        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))

                    } else if indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
                        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
                        path.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
                        path.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
                        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))

                    } else {
                        path.addRect(bounds)
                        addLine = true
                    }

                    layer.path = path
                    layer.fillColor = UIColor.white.withAlphaComponent(0.8).cgColor

                    if addLine {
                        let lineLayer: CALayer = CALayer()
                        let lineHeight: CGFloat = 1.0 / UIScreen.main.scale
                        lineLayer.frame = CGRect(x: bounds.minX + 10.0, y: bounds.size.height - lineHeight, width: bounds.size.width, height: lineHeight)
                        lineLayer.backgroundColor = tableView.separatorColor?.cgColor
                        layer.addSublayer(lineLayer)
                    }

                    let testView: UIView = UIView(frame: bounds)
                    testView.layer.insertSublayer(layer, at: 0)
                    testView.backgroundColor = .clear
                    cell.backgroundView = testView
                }
            }
        }
}
