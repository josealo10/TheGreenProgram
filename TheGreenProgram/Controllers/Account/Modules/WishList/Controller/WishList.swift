//
//  WishList.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/16/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class WishList: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let lineSpacing: CGFloat = 3
    let interItemSpacing: CGFloat = 3
    
    let model = WishListModel()
    
    var refreshControl : UIRefreshControl?
    let searchController = UISearchController(searchResultsController: nil)

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
        navigationController?.navigationBar.tintColor = .primaryTextColor
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = "Wish list"
    }
    
    func configureSearchBar(){
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    @objc func refreshControlHandler(){
        makeRequest()
    }
    
    //MARK:- Request
    func makeRequest(){
        self.model.cleanData();
        let request = RequestManager().getRequest(url: model.url, headers: model.urlHeaderPath, params: [:], method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let str = String(data: data, encoding: .utf8)
                    print(str)
                    let response = try JSONDecoder().decode(ResponseWishList.self, from: data)
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
    extension WishList: UICollectionViewDelegate, UICollectionViewDataSource {
          
          func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return model.getProductsCount()
          }
          
          func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! WishListCell
            
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

    extension WishList: UISearchBarDelegate{
        
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

