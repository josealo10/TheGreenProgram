//
//  Deals.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/20/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class Deals: UIViewController {

    //MARK:- Outlets
    var model: DealsModel = DealsModel()
    var refreshControl: UIRefreshControl?
    let searchController = UISearchController(searchResultsController: nil)
    
    static var locationHasChange = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        configureSearchBar()
        activityIndicator.startAnimating()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if model.deals.isEmpty || Deals.locationHasChange{
            makeDealsRequest()
            Deals.locationHasChange = false
        }
    }
    
    
    //MARK:- ConfigureViewController
    func configureTableView(){
        tableView.tableFooterView = UIView()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshControlHandler), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        tableView.backgroundView?.backgroundColor = .colorBackground
        tableView.backgroundColor = .colorBackground
        tableView.delegate = self
        tableView.dataSource = self
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
        
        navigationItem.searchController = searchController
    }
    
    func configureSearchBar(){
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    //MARK:- Operations methods
    
    @objc func refreshControlHandler(){
        makeDealsRequest()
    }
    
    func extractRequestInformation(response: ResponseDeals){
        if response.data?.customer_in_range == false{
            Alert.showBasicAlert(on: self, with: "Lacation not enable", message: "No stores nerby at your location")
            return
        }
        model.deals = (response.data?.items ?? [])
        model.originalData = (response.data?.items ?? [])
    }
    
    //MARK:- Request
    func makeDealsRequest(){
        model.deals = []
        let request = RequestManager().getRequest(
            url: model.url,
            headers: [],
            params: [:],
            method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ResponseDeals.self, from: data)
                    DispatchQueue.main.async {
                        self.extractRequestInformation(response: response)
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl?.endRefreshing()
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

//MARK:- Extensions



    //MARK:- TableView
extension Deals: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.getDealsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealCell") as! DealsCell
        cell.setView(deal: model.deals[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "dealDetailSegue", sender: nil)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DealDetail {
            destination.model.deal = model.deals[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
    //MARK:- Search bar
extension Deals: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            model.deals = model.originalData.filter{
                ($0.name?.replacingOccurrences(of: " ", with: "").lowercased().contains(searchText.replacingOccurrences(of: "", with: " ").lowercased()) ?? false)
            }
            self.tableView.reloadData()
        }else{
            model.deals = model.originalData
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        model.deals = model.originalData
        self.tableView.reloadData()
    }
}
