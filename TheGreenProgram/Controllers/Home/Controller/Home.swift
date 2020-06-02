//
//  Home.swift
//  TheGreenProgram
//
//  Created by Jose Alonso Alfaro Perez on 11/27/19.
//  Copyright © 2019 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow
class Home: UIViewController {
    
    @IBOutlet weak var imageSliderDeals: ImageSlideshow!
    @IBOutlet weak var dealNameLabel:UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mostSoldProductsColletion: UICollectionView!
    @IBOutlet weak var lastestProductsCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    var currentDeal:Int = 0
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let lineSpacing: CGFloat = 3
    let interItemSpacing: CGFloat = 3
    
    //MARK:-Override methods
    var model = HomeModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tabBarController?.tabBar.tintColor = .colorPrimary
        configureNavigationBar()
        configureCollectionView()
        setupCollectionViewItemSize()
        dealNameLabel.textColor = .white
        activityIndicator.startAnimating()
        self.dealNameLabel.text = ""
        view.backgroundColor = .colorBackground
        containerView.backgroundColor = .colorBackground
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if model.deals.isEmpty || model.mostSoldProducts.isEmpty || model.lastedAddedProducts.isEmpty{
            makeRequest()
        }
    }
    
    //MARK:- Configuration
    
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
    
    func configureDealsShow(){
        
        imageSliderDeals.layer.cornerRadius = 10
        imageSliderDeals.clipsToBounds = true
        imageSliderDeals.layer.shadowColor = UIColor.darkGray.cgColor
        imageSliderDeals.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageSliderDeals.layer.shadowRadius = 4
        imageSliderDeals.layer.shadowOpacity = 0.5
        
        imageSliderDeals.slideshowInterval = 4.0
        
        imageSliderDeals.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        imageSliderDeals.contentScaleMode = UIViewContentMode.scaleAspectFill

        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        imageSliderDeals.pageIndicator = pageControl
        
        var images = [InputSource]()
        for deal in model.deals {
            images.append(
                SDWebImageSource(
                    urlString: deal.image_url ?? "",
                    placeholder: UIImage(named: "no_image")) ?? ImageSource(image: UIImage(named: "no_image")!)
            )
        }
        imageSliderDeals.setImageInputs(images)
        
        imageSliderDeals.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
            imageSliderDeals.addGestureRecognizer(recognizer)
    }
    
    func configureCollectionView(){
        mostSoldProductsColletion.delegate = self
        mostSoldProductsColletion.dataSource = self
        
        lastestProductsCollectionView.delegate = self
        lastestProductsCollectionView.dataSource = self
        
        mostSoldProductsColletion.backgroundColor = .colorBackground
        lastestProductsCollectionView.backgroundColor = .colorBackground
    }

    //MARK:- Collection view setup
    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      updateCollectionViewItemSize()
    }
    
    private func setupCollectionViewItemSize() {
      if collectionViewFlowLayout == nil {
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        
        collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumLineSpacing = lineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
        
        mostSoldProductsColletion.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        lastestProductsCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
      }
    }
    
    private func updateCollectionViewItemSize() {
      let numberOfItemPerRow: CGFloat = 2
      
      let width = (mostSoldProductsColletion.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
      let height = width + (width/3)
      
      collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    @objc func didTap() {
        performSegue(withIdentifier: "dealDetailSegue", sender: nil)
    }
    //MARK:-Funtions
    func extractRequestDealsInformation(response: HomeResponse){
        if response.data?.customer_in_range == false{
            Alert.showBasicAlert(on: self, with: "Lacation not enable", message: "No stores nerby at your location")
            return
        }
        for item in response.data?.items ?? []{
            if item.mostSoldProducts != nil {
                model.mostSoldProducts = item.mostSoldProducts ?? []
            }
            if item.lastestProducts != nil {
                model.lastedAddedProducts = item.lastestProducts ?? []
            }
            if item.deals != nil{
                model.deals = item.deals ?? []
            }
        }
    }
    
    //MARK:-Request
    func makeRequest(){
        model.deals = []
        let request = RequestManager().getRequest(
            url: model.urlDeals,
            headers: [],
            params: [:],
            method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(HomeResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.extractRequestDealsInformation(response: response)
                        self.configureDealsShow()
                        if !self.model.deals.isEmpty{
                            self.dealNameLabel.text = self.model.deals[0].name
                        }
                        self.mostSoldProductsColletion.reloadData()
                        self.lastestProductsCollectionView.reloadData()
                        self.activityIndicator.stopAnimating()
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
    
}

extension Home: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        currentDeal = page
        dealNameLabel.text = model.deals[page].name
    }
}
extension Home:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mostSoldProductsColletion{
            return model.mostSoldProducts.count
        }
        if collectionView == lastestProductsCollectionView{
            return model.lastedAddedProducts.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mostSoldProductsColletion{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostSoldProductCell", for: indexPath) as! HomeProductCell
            
            let product = model.mostSoldProducts[indexPath.item]
            cell.setView(product: product)
            
            return cell
        }
        if collectionView == lastestProductsCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LastAddedProductCell", for: indexPath) as! HomeProductCell
            
            let product = model.lastedAddedProducts[indexPath.item]
            cell.setView(product: product)
            
            return cell
        }
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mostSoldProductsColletion{
            if model.mostSoldProducts[indexPath.item].quantity != 0{
                performSegue(withIdentifier: "mostSoldProductsSegue", sender: self)
            }
            self.mostSoldProductsColletion.deselectItem(at: indexPath, animated: true)
        }
        if collectionView == lastestProductsCollectionView{
            if model.lastedAddedProducts[indexPath.item].quantity != 0{
                performSegue(withIdentifier: "lastestAddedSegue", sender: self)
            }
            self.lastestProductsCollectionView.deselectItem(at: indexPath, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "dealDetailSegue"{
            if let destination = segue.destination as? DealDetail {
                destination.model.deal = model.deals[currentDeal]
            }
        }
        if segue.identifier == "mostSoldProductsSegue"{
            let indexPath = mostSoldProductsColletion.indexPathsForSelectedItems
            if let destination = segue.destination as? ProductDetail {
                let product:Product! = model.mostSoldProducts[indexPath![0].item]
                destination.model.product = product
                destination.model.dealMode = false
                destination.model.editMode = product.quantity_shopping_cart != 0
                destination.model.setFirstValues()
            }
        }
        if segue.identifier == "lastestAddedSegue"{
            let indexPath = lastestProductsCollectionView.indexPathsForSelectedItems
            if let destination = segue.destination as? ProductDetail {
                let product:Product! = model.lastedAddedProducts[indexPath![0].item]
                destination.model.product = product
                destination.model.dealMode = false
                destination.model.editMode = product.quantity_shopping_cart != 0
                destination.model.setFirstValues()
            }
        }
        
    }
    
    
}
