//
//  OrderDetail.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/28/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import MapKit

class OrderDetail: UIViewController {
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var orderName: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var direction: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var pointsEarned: UILabel!
    @IBOutlet weak var trackingBTN: UIButton!
    @IBOutlet weak var paymentImage: UIImageView!
    @IBOutlet weak var paymentMethod: UILabel!
    @IBOutlet weak var finalPrice: UILabel!
    
    @IBOutlet weak var productsTableView: UITableView!
    let sizeCell = 130
    
    @IBOutlet weak var dealsTebleView: UITableView!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var model = OrderDetailModel()
    
    let blankView = UIView()
    
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureBlankView()
        container.bringSubviewToFront(blankView)
        view.bringSubviewToFront(activityIndicator)
        tabBarController?.tabBar.isHidden = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        makeRequest()
    }
    
    //MARK:- Configure methods
    func configureTableView(){
        productsTableView.tableFooterView = UIView()
        productsTableView.delegate = self
        productsTableView.dataSource = self
        productsTableView.isScrollEnabled = false
        
        dealsTebleView.tableFooterView = UIView()
        dealsTebleView.delegate = self
        dealsTebleView.dataSource = self
        dealsTebleView.isScrollEnabled = false
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
    
    func configureBlankView(){
        blankView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(blankView)
        blankView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        blankView.bottomAnchor.constraint(equalTo: container.topAnchor).isActive = true
        blankView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        blankView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
    }
    
    func configureView(){
        storeImage.backgroundColor = .colorPrimary
        storeName.text = model.order?.store_name
        orderName.text = String((model.order?.id)!)
        direction.text = model.order?.shipping_address_details
        note.text = model.order?.note
        pointsEarned.text = String((model.order?.loyalty_points_earned)!)
        trackingBTN.backgroundColor = .colorPrimary
        
        let date = (model.order?.date)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.locale = Locale(identifier: "your_loc_id")
        let convertedDate = dateFormatter.date(from: date)
        guard dateFormatter.date(from: date) != nil else {
        assert(false, "no date from string")
        return
        }
        dateFormatter.dateFormat = "dd-MMMM-yyyy"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let timeStamp = dateFormatter.string(from: convertedDate!)
        print(timeStamp)
        
        self.date.text = timeStamp.replacingOccurrences(of: "-", with: " ")
        
        
        configureMapView()
        paymentMethod.text = model.order?.payment_method
        if model.order?.payment_method == "Cash"{
            paymentImage.image = UIImage(named: "bill")
        }else{
            paymentImage.image = UIImage(named: "crowns")
        }
        finalPrice.text = "CRC " + String(calculateFinalPrice())
    }
    
    func configureMapView(){
        let latitude = (model.order?.shipping_address_latitude)!
        let longitude = (model.order?.shipping_address_longitude)!
        let location = CLLocationCoordinate2D(latitude: latitude,
                                              longitude: longitude)
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
    }
    //MARK:- Functions
    func setUpTabelConstraints(){
        productsTableView.translatesAutoresizingMaskIntoConstraints = false
        var heigt = (model.order?.products?.count ?? 0) * sizeCell
        productsTableView.heightAnchor.constraint(equalToConstant: CGFloat(heigt)).isActive = true
        
        dealsTebleView.translatesAutoresizingMaskIntoConstraints = false
        heigt = 0
        for deal in model.order?.deals ?? []{
            heigt += sizeCell * (deal.products?.count ?? 0)
            heigt += 460
        }
        
        dealsTebleView.heightAnchor.constraint(equalToConstant: CGFloat(heigt)).isActive = true
    }
    
    func calculateFinalPrice() -> Double{
        var n :Double = 0
        for product in model.order?.products ?? []{
            n += (product.price ?? 0) * Double(product.quantity ?? 0)
        }
        for deal in model.order?.deals ?? [] {
            for product in deal.products ?? []{
                n += (product.total_deal_price_applied ?? 0) * Double(product.deals_applied ?? 0)
            }
        }
        return n
    }
    
    //MARK:- Request
    func makeRequest(){
        let request = RequestManager().getRequest(
                url: model.url,
                headers: model.urlHeaders,
                params: [:],
                method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ResponseOrderDetail.self, from: data)
                    self.model.order = response.data?.item
                    DispatchQueue.main.async {
                        self.configureTableView()
                        self.setUpTabelConstraints()
                        self.productsTableView.reloadData()
                        self.configureView()
                        self.view.sendSubviewToBack(self.blankView)
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
    
    //MARK:- Visual events
    @IBAction func trackOrder(_ sender: Any) {
        performSegue(withIdentifier: "trackingSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? StepIndicator {
            destination.status = (model.order?.orderStatusNotes?[0].status)!
        }
    }
    
}
//MARK:-Extensions
extension OrderDetail: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == productsTableView{
            return model.order?.products?.count ?? 0
        }else{
            return model.order?.deals?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == productsTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "productOrder") as! OrderDetailCell
            cell.setView(product: (model.order?.products?[indexPath.row])!)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "dealDetailCell") as! OrderDetailDealCell
            cell.setView(deal: (model.order?.deals?[indexPath.row])!)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == productsTableView{
            return CGFloat(sizeCell)
        }else{
            
            var heigth = 0
            for _ in model.order?.deals?[indexPath.row].products ?? []{
                heigth += sizeCell
            }
            return CGFloat(400 + heigth)
        }
    }
}
