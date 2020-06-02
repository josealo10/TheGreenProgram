//
//  StepIndicator.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 6/1/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import StepIndicator

class StepIndicator: UIViewController {

    @IBOutlet weak var stepIndicator: StepIndicatorView!
    
    var verticalSpacing:CGFloat = 0
    var status:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        configureNavigationBar()
        let heigthStepIndicator = stepIndicator.frame.height
        verticalSpacing = heigthStepIndicator/4
        setView()
        setUpStepIndicator()
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
        
        navigationItem.largeTitleDisplayMode = .never
    }
    func setUpStepIndicator(){
        if status == "AwaitingConfirmation"{
            stepIndicator.currentStep = 1
        }
        if status == "Confirmed"{
            stepIndicator.currentStep = 2
        }
        if status == "Shipping"{
            stepIndicator.currentStep = 3
        }
        if status == "Shipped"{
            stepIndicator.currentStep = 4
        }
    }
    
    func setView(){
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.text = "Awaiting for confirmation"
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        label.leftAnchor.constraint(equalTo: stepIndicator.rightAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        label.centerYAnchor.constraint(equalTo: stepIndicator.topAnchor, constant: 10).isActive = true
        
        
        let label2 = UILabel()
        label2.font = UIFont.boldSystemFont(ofSize: 19)
        label2.text = "Confirmed"
        label2.numberOfLines = 2
        label2.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label2)
        label2.leftAnchor.constraint(equalTo: stepIndicator.rightAnchor, constant: 20).isActive = true
        label2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        label2.centerYAnchor.constraint(equalTo: stepIndicator.topAnchor, constant: verticalSpacing + 30).isActive = true
        
        let label3 = UILabel()
        label3.font = UIFont.boldSystemFont(ofSize: 19)
        label3.text = "On Way"
        label3.numberOfLines = 2
        label3.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label3)
        label3.leftAnchor.constraint(equalTo: stepIndicator.rightAnchor, constant: 20).isActive = true
        label3.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        label3.centerYAnchor.constraint(equalTo: stepIndicator.bottomAnchor, constant: (verticalSpacing * -1) + -30).isActive = true
        
        let label4 = UILabel()
        label4.font = UIFont.boldSystemFont(ofSize: 19)
        label4.text = "Delivered"
        label4.numberOfLines = 2
        label4.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label4)
        label4.leftAnchor.constraint(equalTo: stepIndicator.rightAnchor, constant: 20).isActive = true
        label4.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        label4.centerYAnchor.constraint(equalTo: stepIndicator.bottomAnchor, constant:  -10).isActive = true
        
        
    }

}
