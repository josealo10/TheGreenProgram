//
//  Cart.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/17/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import MapKit
class MyTapGesture: UITapGestureRecognizer {
    var tittle = ""
    var des = ""
    var phone = ""
}
class Cart: UIViewController {

    var model = CartModel()
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var totalPriceTF: UILabel!
    @IBOutlet weak var shippingPriceTF: UILabel!
    @IBOutlet weak var taxesPriceTF: UILabel!
    @IBOutlet weak var finalPriceTF: UILabel!
    
    @IBOutlet weak var resumeLabel: UILabel!
    
    @IBOutlet weak var noteBTN: UIButton!
    @IBOutlet weak var cleanCartBTN: UIButton!
    @IBOutlet weak var changePaymentMethodBTN: UIButton!
    @IBOutlet weak var paymentImage: UIImageView!
    @IBOutlet weak var paymentLabel: UILabel!
    
    @IBOutlet weak var bottonToolBar: UIView!
    @IBOutlet weak var toolBarLabel: UILabel!
    @IBOutlet weak var toolBarBTN: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addresTittle: UILabel!
    
    @IBOutlet weak var topDivader: UIView!
    @IBOutlet weak var middleDivider: UIView!
    @IBOutlet weak var bottonDivader: UIView!
    
    var note:String = ""
    var paymentMethods = [
        paymentMethod(image: UIImage(named: "bill")!,name: "Cash",isSelected: true, value: "Cash"),
        paymentMethod(image: UIImage(named: "crowns")!,name: "Loyalty Points",isSelected: false, value: "loyaltyPoints")
    ]
    
    var frontView: UIView! = UIView()
    
    let emptyCartImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "cart")
        image.tintColor = .systemGray
        
        return image
    }()
    let emptyCartLabel : UILabel = {
        let label = UILabel()
        label.text = "Your cart is empty"
        label.textColor = .systemGray
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    var typeCurrency:String = ""
    
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureFrontView()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emptyCartImage.removeFromSuperview()
        emptyCartLabel.removeFromSuperview()
        view.bringSubviewToFront(frontView)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidAppear(_ animated: Bool) {
        makeCartRequest()
    }
    
    //MARK:- Configuration
    func configureMapView(){
        let latitude = Profile.latitude
        let longitude = Profile.longitude
        let location = CLLocationCoordinate2D(latitude: latitude,
                                              longitude: longitude)
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        addresTittle.text = Profile.address
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    
    
    func configureNavigationBar(){
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = .primaryTextColor
    }
    
    func configureTableView(){
        tableView.backgroundColor = .colorBackground
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureFrontView(){
        frontView.backgroundColor = .white
        view.addSubview(frontView)
        frontView.translatesAutoresizingMaskIntoConstraints = false
        frontView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        frontView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        frontView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        frontView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        
    }
    
    //MARK:- Operations methods
    
    
    
    func setEmptyCartView(){
        frontView.addSubview(emptyCartImage)
        emptyCartImage.translatesAutoresizingMaskIntoConstraints = false
        emptyCartImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyCartImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        emptyCartImage.centerYAnchor.constraint(equalTo: frontView.centerYAnchor).isActive = true
        emptyCartImage.centerXAnchor.constraint(equalTo: frontView.centerXAnchor).isActive = true
        
        frontView.addSubview(emptyCartLabel)
        emptyCartLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyCartLabel.centerXAnchor.constraint(equalTo: frontView.centerXAnchor).isActive = true
        emptyCartLabel.topAnchor.constraint(equalTo: emptyCartImage.bottomAnchor, constant: 30).isActive = true
        
    }
    
    func setView(){
        resumeLabel.text = "Cart resume( " + String(calculateNumberOfProducts()) + " articules)"
        toolBarLabel.text = "Final: " + self.typeCurrency + " " + String(calculateFinalPrice())
        
        toolBarBTN.backgroundColor = .colorPrimary
        toolBarBTN.setTitleColor(.primaryTextColor, for: .normal)
        
        cleanCartBTN.tintColor = .colorPrimary
        changePaymentMethodBTN.tintColor = . colorPrimary
        
        
        paymentLabel.text = findPaymentMethod().name
        paymentImage.image = findPaymentMethod().image
        
        bottonToolBar.layer.shadowColor = UIColor.lightGray.cgColor
        bottonToolBar.layer.shadowOpacity = 0.5
        bottonToolBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        configureMapView()
        
        topDivader.backgroundColor = .colorBackground
        middleDivider.backgroundColor = .colorBackground
        bottonDivader.backgroundColor = .colorBackground
    }
    
    func calculateNumberOfProducts()->Int{
        var n = 0
        for store in model.storeList{
            for _ in store.products ?? []{
                n+=1
            }
        }
        return n
    }
    
    func calculatePrices(){
        totalPriceTF.text = self.typeCurrency + " " + String(calculateTotalPrice())
        shippingPriceTF.text = self.typeCurrency + " " + String(calculateShippingPrice())
        taxesPriceTF.text = self.typeCurrency + " " + String(calculateTaxesPrice())
        finalPriceTF.text = self.typeCurrency + " " + String(calculateFinalPrice())
    }
    
    func calculateTotalPrice() -> Double{
        var n: Double = 0.0
        for store in model.storeList{
            for product in store.products ?? []{
                n += ((product.price ?? 0) * Double(product.quantity_shopping_cart ?? 0))
            }
        }
        return n
    }
    
    func calculateShippingPrice() -> Double{
        var n : Double = 0
        for store in model.storeList{
            n += store.shipping_price!
        }
        return n
    }
    
    func calculateTaxesPrice() -> Double{
        let percentaje:Double = 0.13
        return percentaje * calculateTotalPrice()
    }
    
    func calculateFinalPrice() -> Double{
        return calculateTotalPrice() + calculateTaxesPrice() + calculateShippingPrice()
    }
    
    func extractRequestInformation(response: ResponseCart){
        model.storeList = []
        model.data = []
        for cartItem in response.data?.items ?? [] {
            var store:Store
            store = cartItem.store
            store.shipping_price = 1500
            model.storeList.append(store)
            self.typeCurrency = "CRC"
        }
        
        for store in model.storeList{
            var array:[Any] = []
            for product in store.products ?? []{
                array.append(product)
            }
            for deal in store.deals ?? []{
                array.append(deal)
            }
            model.data.append(array)
        }
        
    }
    
    
    
    func findPaymentMethod()->paymentMethod{
        for pay in paymentMethods{
            if pay.isSelected { return pay}
        }
        return paymentMethod(image: UIImage(named: "bill")!, name: "Cash", isSelected: true, value: "Cash")
    }
    
    //MARK:- View events
    @IBAction func cleanCart(_ sender: Any) {
        model.storeList = []
        setEmptyCartView()
        view.bringSubviewToFront(frontView)
        RequestManager().makeRequestWithBody(on:self, url: model.url, headers: [], params: [:], method: "DELETE", body: [:], withSemaphore: false)
    }
    
    @IBAction func addNote(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Cart", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "noteModal") as! NoteModal
        
        alertVC.note = note
        alertVC.changeNote = {
            (text:String) in
            if text != ""{
                self.noteBTN.setTitle(text, for: .normal)
            }else{
                self.noteBTN.setTitle("Add a note", for: .normal)
            }
            self.note = text
        }
        self.present(alertVC,animated:true)
    }
    
    @IBAction func changePaymentMethod(_ sender: Any) {
        performSegue(withIdentifier: "changePaymentMethod", sender: self)
    }
    @IBAction func shop(_ sender: Any) {
        var loyaltyPointsUsed:Int = 0
        if findPaymentMethod().value == "loyaltyPoints"{
            loyaltyPointsUsed = Int(calculateFinalPrice())
            loyaltyPointsUsed = (loyaltyPointsUsed/10) * 10
        }
        
        let request = RequestManager().getRequestWithBody(
            url: model.orderUrl,
            headers: [],
            params: [:],
            method: "POST",
            body: ["note":note,
                   "loyaltyPointsUsed":String(loyaltyPointsUsed)
            ])
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ResponseMakeOrder.self, from: data)
                    DispatchQueue.main.async {
                        if !(response.success ?? false){
                            Alert.showBasicAlert(on: self, with: "Error", message: "Please change payment method")
                        }else{
                            self.setEmptyCartView()
                            self.view.bringSubviewToFront(self.frontView)
                        }
                    }
                } catch {
                    print("Error al parcear",error)
                }
            }
            if let error = error{
                DispatchQueue.main.async {
                    Alert.showBasicAlert(on: self, with: "Error", message: "\(error.localizedDescription)")
                }
            }
            }.resume()
    }
    
    
    @objc func tapMap(){
        performSegue(withIdentifier: "map_segue", sender: self)
    }
    
    @objc func presentStoreModal(sender : MyTapGesture){
        let storyboard = UIStoryboard(name: "Cart", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "storeModal") as! StoreModal
        alertVC.tittle = sender.tittle
        alertVC.des = sender.des
        alertVC.phone = sender.phone
        self.present(alertVC,animated:true)
    }
    //MARK:- Request
    func makeCartRequest(){
        let request = RequestManager().getRequest(url: model.url, headers: [], params: [:], method: "GET")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ResponseCart.self, from: data)
                    self.extractRequestInformation(response: response)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.calculatePrices()
                        if !self.model.storeList.isEmpty{
                            self.setView()
                            self.view.sendSubviewToBack(self.frontView)
                        }else{
                            self.setEmptyCartView()
                            self.view.bringSubviewToFront(self.frontView)
                        }
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
    
    func updateCartRequest(product:Product, method:String){
        
        var headers : [String] = []
        headers = ["products",String((product.store_product_id)!)]
        
        RequestManager().makeRequestWithBody(
            on:self, 
            url: model.url,
            headers: headers,
            params: [:],
            method: method,
            body: [
                "storeProduct":String((product.store_product_id)!),
                "quantity": String(product.quantity_shopping_cart!)
            ],
            withSemaphore: true
        )
        makeCartRequest()
    }
    
    func updateCart(product:Product){
        //DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        //}
        var method = ""
        
        if product.quantity_shopping_cart == 0 {
            Alert.showDecitionAlert(
                on: self,
                with: "Delete product",
                message: "Are you sure to delete this product?",
                acceptHandler: {
                    method = "DELETE"
                    self.updateCartRequest(product: product, method: method)
                },
                cancelHandler: {
                    product.quantity_shopping_cart!+=1
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            )
        }else{
            method = "PUT"
            updateCartRequest(product: product, method: method)
        }
    }

}

//MARK:-Extension
extension Cart: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.data[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .white
        
        let img = UIImageView(image: UIImage(named: "store"))
        img.tintColor = .colorPrimary
        img.backgroundColor = .colorPrimary
        
        view.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.heightAnchor.constraint(equalToConstant: 20).isActive = true
        img.widthAnchor.constraint(equalToConstant: 20).isActive = true
        img.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        img.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        //---------------
        let label = UILabel()
        label.text = model.storeList[section].name ?? ""
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .primaryDarkTextColor
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 15).isActive = true
        label.centerYAnchor.constraint(equalTo: img.centerYAnchor).isActive = true
        
        let tap = MyTapGesture(target: self, action: #selector(self.presentStoreModal))
        tap.tittle = model.storeList[section].name!
        tap.des = model.storeList[section].description!
        tap.phone = model.storeList[section].phone!
        view.addGestureRecognizer(tap)
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = typeCurrency + " " + String(Double(model.storeList[section].shipping_price!))
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .primaryDarkTextColor
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        //---------------
        let img = UIImageView(image: UIImage(named: "entrega"))
        img.tintColor = .colorPrimary
        
        view.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.heightAnchor.constraint(equalToConstant: 20).isActive = true
        img.widthAnchor.constraint(equalToConstant: 20).isActive = true
        img.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10).isActive = true
        img.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        
        
        let footer = UIView()
        footer.backgroundColor = .colorBackground
        
        
        let divider1 = UIView()
        divider1.backgroundColor = .lightGray
        footer.addSubview(divider1)
        divider1.translatesAutoresizingMaskIntoConstraints = false
        divider1.topAnchor.constraint(equalTo: footer.topAnchor).isActive = true
        divider1.leftAnchor.constraint(equalTo: footer.leftAnchor).isActive = true
        divider1.rightAnchor.constraint(equalTo: footer.rightAnchor).isActive = true
        divider1.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
        
        let divider2 = UIView()
        divider2.backgroundColor = .lightGray
        footer.addSubview(divider2)
        divider2.translatesAutoresizingMaskIntoConstraints = false
        divider2.bottomAnchor.constraint(equalTo: footer.bottomAnchor).isActive = true
        divider2.leftAnchor.constraint(equalTo: footer.leftAnchor).isActive = true
        divider2.rightAnchor.constraint(equalTo: footer.rightAnchor).isActive = true
        divider2.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
        
        
        view.addSubview(footer)
        footer.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        footer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        footer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 65
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if model.data[indexPath.section][indexPath.row] is Product{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell") as! CartCell
            let product = model.data[indexPath.section][indexPath.row] as! Product
            cell.setView(product:product)
            cell.updateProduct = { self.updateCart(product: product)}
            return cell
        }
        if model.data[indexPath.section][indexPath.row] is Deal{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cartDealCell") as! CartDealCell
            let deal = model.data[indexPath.section][indexPath.row] as! Deal
            cell.setView(name: deal.name ?? "", finalPrice: deal.total_price ?? 0, image: deal.image_url ?? "", typeCurrency: self.typeCurrency,description: deal.description ?? "")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if model.data[indexPath.section][indexPath.row] is Product{
            performSegue(withIdentifier: "productItemSegue", sender:self)
        }
        if model.data[indexPath.section][indexPath.row] is Deal{
            performSegue(withIdentifier: "dealDetailSegue", sender:self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if segue.identifier == "productItemSegue"{
            if let destination = segue.destination as? ProductDetail {
                let product = model.data[indexPath!.section][indexPath!.row] as! Product
                destination.model.product = product
                destination.model.dealMode = false
                destination.model.editMode = true
                destination.model.setFirstValues()
            }
        }
        if segue.identifier == "dealDetailSegue"{
            if let destination = segue.destination as? DealDetail {
                destination.model.deal = model.data[indexPath!.section][indexPath!.row] as? Deal
            }
        }
        if segue.identifier == "changePaymentMethod"{
            if let destination = segue.destination as? PaymentMethod {
                
                destination.paymentMethods = self.paymentMethods
                destination.changePaymentMethod = {
                    (paymentMethods) in
                    self.paymentMethods = paymentMethods
                }
            }
        }
    }
}
