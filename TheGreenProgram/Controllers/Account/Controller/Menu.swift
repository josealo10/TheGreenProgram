//
//  ViewController.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit
import Foundation
import AWSMobileClient

private let reuseIdentifier = "SettingsCell"

class Menu: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    //MARK:-Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        view.backgroundColor = UIColor.colorBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Configuration
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        let footer = UIView()
        let divider = UIView()
        divider.backgroundColor = .darkGray
        footer.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.topAnchor.constraint(equalTo: footer.topAnchor).isActive = true
        divider.leftAnchor.constraint(equalTo: footer.leftAnchor).isActive = true
        divider.rightAnchor.constraint(equalTo: footer.rightAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        
        tableView.tableFooterView = footer
        tableView.backgroundColor = UIColor.colorBackground
        
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.tintColor = .primaryTextColor
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
    }
    
    
    //MARK:- Functions
    func logout(){
        let alert = UIAlertController(title: "Do you want to logout?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
            AWSMobileClient.default().signOut()
        }))
        
        self.present(alert, animated: true)
    }
}

// MARK: - Extension TableView
extension Menu: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
        case .profile : return profile.allCases.count
        case .myOptions: return myOptions.allCases.count
        case .logout: return logOut.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let divider1 = UIView()
        divider1.backgroundColor = .darkGray
        view.addSubview(divider1)
        divider1.translatesAutoresizingMaskIntoConstraints = false
        divider1.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        divider1.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        divider1.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        divider1.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        
        let divider2 = UIView()
        divider2.backgroundColor = .darkGray
        view.addSubview(divider2)
        divider2.translatesAutoresizingMaskIntoConstraints = false
        divider2.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        divider2.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        divider2.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        divider2.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
        case .profile : return 0
        case .myOptions: return 40
        case .logout: return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = SettingsSection(rawValue: indexPath.section) else { return 60.0}
        
        switch section {
        case .profile: return 100.0
        default: return 60.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsCell()
        
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .profile:
            let pro = profile(rawValue: indexPath.row)
            cell.sectionType = pro
        case .myOptions:
            let myoptions = myOptions(rawValue: indexPath.row)
            cell.sectionType = myoptions
        case .logout:
            let log = logOut(rawValue: indexPath.row)
            cell.sectionType = log
        }
        
        
        cell.setView()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .profile:
            switch profile(rawValue: indexPath.row){
            case .profile: performSegue(withIdentifier: "myAccount", sender: self)
            case .none:print("")
            }
            
        case .myOptions:
            switch myOptions(rawValue: indexPath.row) {
            case .myPoints: performSegue(withIdentifier: "myPoints", sender: self)
            case .myOrders: performSegue(withIdentifier: "myOrders", sender: self)
            case .wish: performSegue(withIdentifier: "wishListSegue", sender: self)
            case .none:print("")
            }
            
        case .logout:
            switch logOut(rawValue: indexPath.row){
            case .logout: self.logout()
            case .none:print("")
            }
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

