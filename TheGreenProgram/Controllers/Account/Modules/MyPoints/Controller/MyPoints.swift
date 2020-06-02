//
//  MyPoints.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 4/6/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class MyPoints: UIViewController {
    
    let model = MyPointsModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var conteinerView: UIView!
    
    @IBOutlet weak var informationView: UIView!
    
    var level:LoyaltyLevel?
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        setupCollectionViewItemSize()
        activityIndicator.startAnimating()
        view.backgroundColor = .colorBackground
        conteinerView.backgroundColor = .colorBackground
        informationView.backgroundColor = UIColor.white
        informationView.layer.cornerRadius = 10.0
        informationView.layer.masksToBounds = false
        
        informationView.layer.shadowColor = UIColor.lightGray.cgColor
        informationView.layer.shadowOffset = CGSize(width: 0, height: 0)
        informationView.layer.shadowOpacity = 0.8
    }
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        if model.levels.isEmpty{
            makeRequest()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK:- Configure
    func configureNavigationBar(){
        navigationController?.navigationBar.tintColor = .primaryTextColor
        navigationController?.navigationBar.backgroundColor = .colorPrimary
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = "My points"
    }
    
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func extactRequestInformation(response:LoyaltyResponse){
        self.model.levels = response.data?.items ?? []
        for n in 0...model.levels.count - 1{
            if n != model.levels.count - 1{
                model.levels[n].nextLevel = model.levels[n+1]
            }
        }
    }
    //MARK:- Visual events
    
    
    //MARK:- Resquest
    func makeRequest(){
        let request = RequestManager().getRequest(
            url: model.url,
            headers: [],
            params: [:],
            method: "GET")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
        if let data = data {
            do {
                let response = try JSONDecoder().decode(LoyaltyResponse.self, from: data)
                self.extactRequestInformation(response: response)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            } catch {
                print("Error al parcear",error)
                self.activityIndicator.stopAnimating()
            }
        }
        if let error = error{
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                Alert.showBasicAlert(on: self, with: "Error", message: "\(error.localizedDescription)")
            }
        }
        }.resume()
        
    }
    
    override func viewWillLayoutSubviews() {
           super.viewWillLayoutSubviews()
           updateCollectionViewItemSize()
         }
    
    private func setupCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .horizontal
            collectionViewFlowLayout.minimumLineSpacing = 1
            collectionViewFlowLayout.minimumInteritemSpacing = 1
            
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
            collectionView.backgroundColor = .colorBackground
        }
    }
         
         private func updateCollectionViewItemSize() {
           let numberOfItemPerRow: CGFloat = 1
           
           let width = (collectionView.frame.width - (numberOfItemPerRow - 1) * 1) / numberOfItemPerRow
            let height:CGFloat = 400
           
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
         }

}

//MARK:- Extensions
extension MyPoints: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "levelCell", for: indexPath) as! LevelCell
        cell.setView(level: model.levels[indexPath.item])
        cell.seeMore = {
            self.level = self.model.levels[indexPath.item]
            self.performSegue(withIdentifier: "benefitsSegue", sender: self)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? benefitsList {
            destination.level = level
        }
    }
    
    
}
