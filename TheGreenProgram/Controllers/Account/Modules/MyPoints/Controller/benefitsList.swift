//
//  benefitsList.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/14/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class benefitsList: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelImage: UIImageView!
    var level:LoyaltyLevel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .white
        levelLabel.text = level?.name
        levelImage.backgroundColor = UIColor().colorFromHex(level?.color ?? "#0000")
        tabBarController?.tabBar.isHidden = true
        configureNavigationBar()
    }
    
    func configureNavigationBar(){
        navigationItem.largeTitleDisplayMode = .never
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = ""
    }
}

//MARK:- Extension
extension benefitsList:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return level?.benefits?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let benefit = UILabel()
        benefit.text = "• " + (level?.benefits?[indexPath.row])!
        benefit.translatesAutoresizingMaskIntoConstraints = false
        
        cell.addSubview(benefit)
        benefit.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 20).isActive = true
        benefit.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
}
