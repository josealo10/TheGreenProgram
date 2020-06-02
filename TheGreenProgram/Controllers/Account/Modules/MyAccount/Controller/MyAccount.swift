//
//  MyAccount.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/12/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class MyAccount: UIViewController {
    
    var editMode: Bool = false
    let model = MyAccountModel()
    
    var nameTF: UITextField?
    var surnameTF: UITextField?
    var genderTF: UITextField?
    var phone_numberTF: UITextField?
    var addressTF: UITextField?
    
    var birthdaySelected:String?
    var phoneNumber:String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leftButton: UIButton!
    
    //MARK:-Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTap))
        model.refreshData()
        configurateTableView()
        configurateNavigationView()
        birthdaySelected = Profile.birthday
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        self.view.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        model.refreshData()
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    //MARK:-Configuration
    func configurateTableView(){
        let footer = UIView()
        footer.backgroundColor = .colorBackground
        tableView.tableFooterView = footer
        tableView.backgroundColor = .colorBackground
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configurateNavigationView(){
        navigationController?.navigationBar.tintColor = .primaryTextColor
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        
        view.backgroundColor = .colorBackground
    }
    
    //MARK:-View events
    @IBAction func backTap(_ sender: Any) {
        
        if editMode {
            editMode = !editMode
            model.refreshData()
            tableView.reloadData()
            navigationItem.rightBarButtonItem?.title = "Edit"
            leftButton.setTitle("Back", for: .normal)
            leftButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc func editTap(){
        editMode = !editMode
        if editMode{
        navigationItem.rightBarButtonItem?.title = "OK"
            leftButton.setTitle("Cancel", for: .normal)
            leftButton.setImage(UIImage(), for: .normal)
        }else{
            //change attributes
            
            var name = Profile.name
            var lastname = Profile.surname
            var gender = Profile.gender
            var phoneNumber = Profile.phone_number
            var dateBirth = Profile.birthday
            
            if nameTF?.text != ""{
                name = nameTF?.text ?? ""
            }
            if surnameTF?.text != ""{
                lastname = surnameTF?.text ?? ""
            }
            if genderTF?.text != ""{
                gender = genderTF!.text!
            }
            if phone_numberTF?.text != ""{
                var str = phone_numberTF!.text!
                str = phoneNumber.replacingOccurrences(of: "+", with: "")
                if str.count == 11{
                    phoneNumber = "+" + str
                }
            }
            if birthdaySelected != ""{
                dateBirth = birthdaySelected!
            }
            
            let body = [
                "name": name,
                "lastname":lastname,
                "gender":gender,
                "phoneNumber":phoneNumber,
                "dateBirth":dateBirth
            ]
            
            Profile.name = name
            Profile.surname = lastname
            Profile.gender = gender
            Profile.phone_number = phoneNumber
            Profile.birthday = dateBirth
            
            RequestManager().makeRequestWithBody(on: self, url: model.url, headers: [], params: [:], method: "PUT", body: body, withSemaphore: true)
            
            leftButton.setTitle("Back", for: .normal)
            leftButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
        model.refreshData()
        tableView.reloadData()
    }
    
    @objc func tapGestureDone(){
        view.endEditing(true)
    }
}

//MARK:- Extensions
extension MyAccount: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !editMode{
            return model.sections.count
        }else{
            return model.editSections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !editMode {
            let section = model.sections[section].0
            switch section {
                case "Information": return model.information.count
                case "Security": return 1
                default:return 0
            }
        }else{
            let section = model.editSections[section].0
            switch section {
            case "Information": return model.editInformation.count
                default:return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MyAccountCell()
        if !editMode {
            let section = model.sections[indexPath.section].0
            switch section {
                case "Information":
                    cell.configureInformation(
                        description: model.information[indexPath.row].0,
                        value: model.information[indexPath.row].1
                    )
                case "Security":
                    cell.configureSegurity(
                        description: model.securityOption
                    )
                    cell.changePassword = {
                        self.performSegue(withIdentifier: "change_password", sender: self)
                    }
            default: break
            }
            return cell
        }else{
            cell.configureEditView(
                type: model.editInformation[indexPath.row].0,
                description: model.editInformation[indexPath.row].1,
                value: model.editInformation[indexPath.row].2
            )
            
            switch model.editInformation[indexPath.row].0 {
            case "Name": nameTF = cell.valueTextFiel
            case "Surname": surnameTF = cell.valueTextFiel
            case "Gender": genderTF = cell.valueTextFiel
            case "Birthdate":
                cell.birthdaySelected = self.birthdaySelected
                cell.changeBirthdate = {
                    (birthDate) in
                    self.birthdaySelected = birthDate
                }
            case "phone_number":
                phone_numberTF = cell.valueTextFiel
            case "Address":
                addressTF = cell.valueTextFiel
                cell.showMap = {
                    self.performSegue(withIdentifier: "map_segue", sender: self)
                    self.view.endEditing(true)
                }
            default:
                break
            }
             
            return cell
        }
    }
    

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .lightGray
        if !editMode{
            title.text = model.sections[section].1
        }else{
            title.text = model.editSections[section].1
        }
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        if !editMode && model.sections[section].0 == "Information"{
            let title = UILabel()
            title.font = UIFont.systemFont(ofSize: 16)
            title.textColor = .lightGray
            title.numberOfLines = 0
            title.backgroundColor = .colorBackground
            title.text = "This email address is your user ID and cannot be changed "
            
            view.addSubview(title)
            title.translatesAutoresizingMaskIntoConstraints = false
            title.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
            title.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !editMode {
            view.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !editMode && model.sections[section].0 == "Information"{return 50}
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
