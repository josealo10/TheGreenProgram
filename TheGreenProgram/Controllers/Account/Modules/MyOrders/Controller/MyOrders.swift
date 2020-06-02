//
//  MyOrders.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/11/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class MyOrders: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var allBTN: UIButton!
    @IBOutlet weak var awaittingConfirmationBTN: UIButton!
    @IBOutlet weak var confirmedBTN: UIButton!
    @IBOutlet weak var cancelledBTn: UIButton!
    @IBOutlet weak var shippingBTN: UIButton!
    @IBOutlet weak var deliveredBTN: UIButton!
    
    
    @IBOutlet weak var tabStackView: UIStackView!
    
    @IBOutlet weak var tabTitle: UILabel!
    
    var refreshControl: UIRefreshControl?
    
    var model = MyOrdersModel()
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        configureTableView()
        configureNavigationBar()
        configureView()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        if model.orders.isEmpty{
            makeRequest()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    
    //MARK:- Configure methods
    
    func configureView(){
        allBTN.backgroundColor = .colorPrimary
        awaittingConfirmationBTN.backgroundColor = .colorPrimary
        confirmedBTN.backgroundColor = .colorPrimary
        cancelledBTn.backgroundColor = .colorPrimary
        shippingBTN.backgroundColor = .colorPrimary
        deliveredBTN.backgroundColor = .colorPrimary
        
        allBTN.tintColor = .primaryTextColor
        awaittingConfirmationBTN.tintColor = .primaryTextColor
        confirmedBTN.tintColor = .primaryTextColor
        cancelledBTn.tintColor = .primaryTextColor
        shippingBTN.tintColor = .primaryTextColor
        deliveredBTN.tintColor = .primaryTextColor
        
        tabTitle.text = "All orders"
    }
    
    func configureTableView(){
        tableView.tableFooterView = UIView()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshControlHandler), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        tableView.backgroundView?.backgroundColor = .colorBackground
        tableView.backgroundColor = .colorBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .colorBackground
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
        navigationItem.title = "My orders"
    }
    //MARK:- Functions
    @objc func refreshControlHandler(){
        makeRequest()
    }
    
    //MARK:- Visual events
    
    @IBAction func allTabSelected(_ sender: Any) {
        tabTitle.text = "All orders"
        model.orders = model.all
        model.setParams(fromItem: "0", itemsQuantity: "50", status: "")
        changeTab()
    }
    @IBAction func awattingConfirmationTabSelected(_ sender: Any) {
        tabTitle.text = "Awaiting for Confirmation"
        model.orders = model.awaitting
        model.setParams(fromItem: "0", itemsQuantity: "50", status: "AwaitingConfirmation")
        changeTab()
    }
    @IBAction func confirmedTabSelected(_ sender: Any) {
        tabTitle.text = "Confirmed Orders"
        model.orders = model.confirmed
        model.setParams(fromItem: "0", itemsQuantity: "50", status: "Confirmed")
        changeTab()
    }
    @IBAction func cancelledTabSelected(_ sender: Any) {
        tabTitle.text = "Canceled Orders"
        model.orders = model.cancelled
        model.setParams(fromItem: "0", itemsQuantity: "50", status: "Canceled")
        changeTab()
    }
    @IBAction func shippingTabSelected(_ sender: Any) {
        tabTitle.text = "On Way"
        model.orders = model.shipping
        model.setParams(fromItem: "0", itemsQuantity: "50", status: "Shipping")
        changeTab()
    }
    @IBAction func deliveredTabSelected(_ sender: Any) {
        tabTitle.text = "Delivered Orders"
        model.orders = model.delivered
        model.setParams(fromItem: "0", itemsQuantity: "50", status: "Shipped")
        changeTab()
    }
    
    func changeTab(){
        tableView.reloadData()
        if model.orders.isEmpty{
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            makeRequest()
        }
    }
    
    //MARK:- Requests
    func makeRequest(){
        model.orders = []
        let request = RequestManager().getRequest(
            url: model.url,
            headers: [],
            params: model.params,
            method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ResponseOrder.self, from: data)
                    DispatchQueue.main.async {
                        self.model.orders = response.data?.items ?? []
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let destination = segue.destination as? OrderDetail {
            destination.model.urlHeaders = [String((model.orders[indexPath!.row].id)!)]
        }
    }
}

//MARK:- Extensions
extension MyOrders:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell") as! MyOrdersCell
        cell.setView(order: model.orders[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "orderDetailSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
}
