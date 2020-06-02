//
//  Categories.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/10/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData


class Categories: UIViewController {
    
    var model: CategorieModel = CategorieModel()
    var refreshControl: UIRefreshControl?
    let searchController = UISearchController(searchResultsController: nil)
    
    static var locationHasChange = false

    @IBOutlet weak var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var searchCollectionViewFlowLayout: UICollectionViewFlowLayout!
    let lineSpacing: CGFloat = 3
    let interItemSpacing: CGFloat = 3
    
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupCollectionViewItemSize()
        configureNavigationView()
        configureCollectionView()
        configureSearchHistory()
        configureSearchBar()
        configureSearchTableView()
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if model.data.isEmpty || Categories.locationHasChange{
            self.makeCategoriesRequest()
            Categories.locationHasChange = false
        }
    }
    
    //MARK:-Configuration
    func configureNavigationView(){
        navigationController?.navigationBar.tintColor = .primaryTextColor
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.title = "Categories"
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.searchController = searchController
    }
    
    func configureCollectionView(){
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshControlHandler), for: .valueChanged)
        collectionView.addSubview(refreshControl!)
        collectionView.backgroundColor = .colorBackground
        searchCollectionView.backgroundColor = .colorBackground
        view.backgroundColor = .colorBackground
    }
    
    func configureSearchBar(){
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func configureSearchTableView(){
        searchTableView.tableFooterView = UIView()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        view.sendSubviewToBack(searchTableView)
        view.sendSubviewToBack(searchCollectionView)
    }
    
    func configureSearchHistory(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchHistory")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]{
                let str = data.value(forKey: "searchString") as! String
                model.searHistory.insert(str, at: 0)
            }
            model.searchOriginalHistory = model.searHistory
        }catch{print("Failed getting data")}
    }
    
    //MARK:- Operations methods
    
    @objc func refreshControlHandler(){
        self.makeCategoriesRequest()
    }
    
    func updateTableRows(deleteIndexPath:[IndexPath],insertIndexPath:[IndexPath]){
        collectionView.deleteItems(at: deleteIndexPath)
        collectionView.insertItems(at: insertIndexPath)
    }
    
    func extracRequestInformation(response:ResponseCategories){
        if response.data?.items?.isEmpty ?? true{
            Alert.showBasicAlert(on: self, with: "Lacation not enable", message: "No stores nerby in your location")
            return
        }
        for category in response.data?.items ?? []{
            let node = Node(category: category)
            model.addNodeChild(node: node)
        }
    }
    
    //MARK:- Requests
    func makeCategoriesRequest(){
        model.cleanData()
        let request = RequestManager().getRequest(url: model.urlCategories, headers: model.urlHeaderPathCategories, params: [:], method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ResponseCategories.self, from: data)
                    self.extracRequestInformation(response: response)
                    self.model.refreshData()
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl?.endRefreshing()
                    }
                } catch {
                    self.activityIndicator.stopAnimating()
                }
            }
            if let error = error {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    Alert.showBasicAlert(on: self, with: "Error", message: "\(error.localizedDescription)")
                }
            }
            }.resume()
    }
    
    func makeSearchRequest(){
        model.searchData = []
        let request = RequestManager().getRequest(url: model.urlSearch, headers: [], params: model.searchParams, method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    self.model.searchData = response.data?.items ?? []
                    DispatchQueue.main.async {
                        self.searchCollectionView.reloadData()
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
    
    //MARK:- Visual events
    @IBAction func bacTap(_ sender: Any) {
        let deleteIndexPath = model.getDataIndexPath()
        
        model.moveToParent()
        model.refreshData()
        navigationItem.title = model.getTreeIterator().category.name
        let insertIndexPath = model.getDataIndexPath()
        model.setURLHeaderPath(urlHeaderPath: [String( (model.getTreeIterator().category.id!)),"subCategories"])
        updateTableRows(deleteIndexPath: deleteIndexPath, insertIndexPath: insertIndexPath)
        
        if model.getTreeIterator().category.name == "root"{
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.title = "Categories"
            model.setURLHeaderPath(urlHeaderPath: [])
        }
    }
    
    @IBAction func cartButtonPass(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    
    //MARK:- Collection view setup
      override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCollectionViewItemSize()
      }

      private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
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
        if searchCollectionViewFlowLayout == nil {
          searchCollectionViewFlowLayout = UICollectionViewFlowLayout()
          
          searchCollectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
          searchCollectionViewFlowLayout.scrollDirection = .vertical
          searchCollectionViewFlowLayout.minimumLineSpacing = lineSpacing
          searchCollectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
          
          searchCollectionView.setCollectionViewLayout(searchCollectionViewFlowLayout, animated: true)
        }
      }
      
      private func updateCollectionViewItemSize() {
        let numberOfItemPerRow: CGFloat = 2
        
        let width = (collectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
        var height = width
        
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
        
        height = width + (width/3)
        searchCollectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
      }
      
    }




//MARK: - Extensions



    //MARK:- Collection view extension
extension Categories:  UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView{
            return model.getDataCount()
        }else{
            return model.searchData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categorieCell", for: indexPath) as! CategorieCell
            
            cell.setView(image: model.data[indexPath.row].image_url ?? "", name: model.data[indexPath.row].name ?? "")
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            
            let product = model.searchData[indexPath.item]
            cell.setView(product: product)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView{
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            let deleteIndexPath = model.getDataIndexPath()
            if (model.getChild(child: model.data[indexPath.row].id!).category.has_subCategories!){
                self.activityIndicator.startAnimating()
                model.moveToChild(child: model.data[indexPath.row].id!)
                
                if (model.getTreeIterator().children.isEmpty){
                    model.setURLHeaderPath(urlHeaderPath: [String( (model.getTreeIterator().category.id!)),"subCategories"])
                    self.makeCategoriesRequest()
                }
                
                model.refreshData()
                self.activityIndicator.stopAnimating()
            }else{
                ProductList.categorieId = model.getChild(child: model.data[indexPath.row].id!).category.id!
                ProductList.categorieName = model.getChild(child: model.data[indexPath.row].id!).category.name ?? ""
                ProductList.categorieImage = model.getChild(child: model.data[indexPath.row].id!).category.image_url!
                performSegue(withIdentifier: "products", sender: self)
            }
            self.navigationItem.title = model.getTreeIterator().category.name
            self.searchController.isActive = false
            let insertIndexPath = model.getDataIndexPath()
            updateTableRows(deleteIndexPath: deleteIndexPath, insertIndexPath: insertIndexPath)
        }
        else{
            if model.searchData[indexPath.item].quantity != 0{
                performSegue(withIdentifier: "productItemSegue", sender: self)
            }
            self.searchCollectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productItemSegue"{
            let indexPath = searchCollectionView.indexPathsForSelectedItems
            if let destination = segue.destination as? ProductDetail {
                let product:Product! = model.searchData[indexPath![0].item]
                destination.model.product = product
                destination.model.dealMode = false
                destination.model.editMode = product.quantity_shopping_cart != 0
                destination.model.setFirstValues()
            }
        }
    }
}

    //MARK:- Search bar extension
extension Categories: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0 {
            self.model.searHistory = self.model.searchOriginalHistory.filter{
                ($0.replacingOccurrences(of: " ", with: "").lowercased().contains(searchText.replacingOccurrences(of: "", with: " ").lowercased()) )
            }
            self.searchTableView.reloadData()
        }else{
            model.searHistory = model.searchOriginalHistory
            self.searchTableView.reloadData()
        }
         
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        model.searHistory = model.searchOriginalHistory
        var str = ""
        if searchBar.text != ""{
            var flag = true
            for key in model.searHistory{
                if key == searchBar.text{
                    flag = false
                    break
                }
            }
            if flag {
                str = searchBar.text ?? ""
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "SearchHistory", in: context)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                
                newEntity.setValue(str, forKey: "searchString")
                
                do{
                    try context.save()
                    print("Saved")
                }catch{print("Failed saving")}
                
                model.searHistory.insert(str, at: 0)
                model.searchOriginalHistory = model.searHistory
            }
            view.sendSubviewToBack(searchTableView)
            view.bringSubviewToFront(searchCollectionView)
            view.bringSubviewToFront(activityIndicator)
            activityIndicator.startAnimating()
            model.setSearchParams(fromItem: "0", itemsQuantity: "50", filterName: str)
            //make request
            makeSearchRequest()
            
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.sendSubviewToBack(searchCollectionView)
        navigationItem.leftBarButtonItem?.isEnabled = true
        if model.getTreeIterator().category.name == "root"{
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.title = NSLocalizedString("Categories", comment: "")
            model.setURLHeaderPath(urlHeaderPath: [])
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.leftBarButtonItem?.isEnabled = false
        searchTableView.reloadData()
        view.bringSubviewToFront(searchTableView)
        view.sendSubviewToBack(searchCollectionView)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            view.sendSubviewToBack(searchCollectionView)
        }
        view.sendSubviewToBack(searchTableView)
        model.searHistory = model.searchOriginalHistory
    }
}

//MARK:- Table View extension
extension Categories: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.searHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let image = UIImageView()
        image.image = UIImage(systemName: "gobackward")
        image.tintColor = .colorPrimary
        image.translatesAutoresizingMaskIntoConstraints = false
        
        cell.addSubview(image)
        image.heightAnchor.constraint(equalToConstant: 20).isActive = true
        image.widthAnchor.constraint(equalToConstant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 20).isActive = true
        image.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        
        let title = UILabel()
        title.text = model.searHistory[indexPath.row]
        title.translatesAutoresizingMaskIntoConstraints = false
        
        cell.addSubview(title)
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
        title.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.dismiss(animated: true) { () -> Void in
            self.view.sendSubviewToBack(self.searchTableView)
            self.model.searHistory = self.model.searchOriginalHistory
        }
        self.searchController.searchBar.text = self.model.searHistory[indexPath.row]
        model.setSearchParams(fromItem: "0", itemsQuantity: "50", filterName: model.searHistory[indexPath.row])
        //request
        view.bringSubviewToFront(searchCollectionView)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        makeSearchRequest()
        searchTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
