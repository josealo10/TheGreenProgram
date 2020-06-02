//
//  ProductsListViewController.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/5/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

class ProductList: UIViewController {


    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let lineSpacing: CGFloat = 3
    let interItemSpacing: CGFloat = 3
    
    static var categorieId:Int = 0
    static var categorieName: String = ""
    static var categorieImage: String = ""
    
    let model : ProductListModel = ProductListModel()
    
    var refreshControl : UIRefreshControl?
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK:- Override methods
      override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupCollectionViewItemSize()
        configureCollectionView()
        configureNavigationBar()
        configureSearchBar()
        activityIndicator.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
      
    override func viewDidAppear(_ animated: Bool) {
        if model.products.isEmpty{
            model.setURLHeaderPath(urlHeaderPath: [String(ProductList.categorieId),"products"])
            self.makeRequest()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK:- Configuration
    func configureCollectionView(){
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshControlHandler), for: .valueChanged)
        collectionView.addSubview(refreshControl!)
        collectionView.backgroundColor = .colorBackground
        view.backgroundColor = .colorBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func configureNavigationBar(){
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
       
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        /*
        SDWebImageDownloader.shared.downloadImage(
            with: URL(string:  ProductList.categorieImage),
        options: [.highPriority],
        progress: { (receivedSize, expectedSize, url) in
            /// progress tracking code
        },
        completed: { [weak self] (image, data, error, finished) in
           if let image = image, finished {
              /// do something with image
              /// eg. self?.imageView.image = image
            self?.navigationItem.scrollEdgeAppearance?.backgroundImage = image
           }
        })
         */
        navigationItem.searchController = searchController
        navigationItem.title = ProductList.categorieName
    }
    
    func configureSearchBar(){
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    @objc func refreshControlHandler(){
        makeRequest()
    }
    //MARK:- View events
    @IBAction func cartButtonPass(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    
    //MARK:- Request
    func makeRequest(){
        self.model.cleanData();
        let request = RequestManager().getRequest(url: model.url, headers: model.urlHeaderPath, params: [:], method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    self.model.products = response.data?.items ?? []
                    self.model.originalData = response.data?.items ?? []
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.refreshControl?.endRefreshing()
                        self.activityIndicator.stopAnimating()
                    }
                } catch {
                    print("Error al parcear",error)
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
    
    //MARK:- Collection view setup
      override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCollectionViewItemSize()
      }

      private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
      }
      
      private func setupCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
          collectionViewFlowLayout = UICollectionViewFlowLayout()
          
          collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
          collectionViewFlowLayout.scrollDirection = .vertical
          collectionViewFlowLayout.minimumLineSpacing = lineSpacing
          collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
          
          collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
      }
      
      private func updateCollectionViewItemSize() {
        let numberOfItemPerRow: CGFloat = 2
        
        let width = (collectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
        let height = width + (width/3)
        
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
      }
      
    }

//MARK:- Extensions
extension ProductList: UICollectionViewDelegate, UICollectionViewDataSource {
      
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.getProductsCount()
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        let product = model.products[indexPath.item]
        cell.setView(product: product)
        
        return cell
      }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model.products[indexPath.item].quantity != 0{
            performSegue(withIdentifier: "productItemSegue", sender: self)
        }
        self.collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems
        if let destination = segue.destination as? ProductDetail {
            let product:Product! = model.products[indexPath![0].item]
            destination.model.product = product
            destination.model.dealMode = false
            destination.model.editMode = product.quantity_shopping_cart != 0
            destination.model.setFirstValues()
        }
    }
      
    }

extension ProductList: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            model.products = model.originalData.filter{
                ($0.name?.replacingOccurrences(of: " ", with: "").lowercased().contains(searchText.replacingOccurrences(of: "", with: " ").lowercased()) ?? false)
            }
            collectionView.reloadData()
        }else{
            model.products = model.originalData
            collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        model.products = model.originalData
        collectionView.reloadData()
    }
}
