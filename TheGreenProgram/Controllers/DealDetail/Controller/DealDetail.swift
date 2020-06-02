//
//  DealDeatail.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/28/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class DealDetail: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var endDayLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var finalPriceWithNoDealLabel: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var dealLabel: UILabel!
    @IBOutlet weak var applyDealBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var typeCurrency = ""
    
    let blankPage = UIView()
    
    var model: DealDetailModel = DealDetailModel()
    var cellHeigth = 70
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        presentBlankPage()
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        if !(model.deal?.products?.isEmpty ?? true){
            tableView.reloadData()
            updateView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (model.deal?.products?.isEmpty ?? true){
            makeRequest()
            activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.tintColor = .primaryTextColor
    }
    
    //MARK:- Configurations
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(cellHeigth * (model.deal?.products?.count ?? 0))).isActive = true
        tableView.isScrollEnabled = false
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
    
    func setView(){
        image.sd_setImage(with: URL(string: (model.deal?.image_url)!), placeholderImage: UIImage(named: "no_image"), completed: nil)
        nameLabel.text = model.deal?.name
        endDayLabel.text = "Time limit: " + applyDateFormat(dealDate: (model.deal?.end_date)!) + " while supplies last"
        descriptionLabel.text = model.deal?.description
        findTypeCurrency()
        if model.deal?.type == "percentageDiscount"{
            dealLabel.text = " " + String(model.deal!.percentage_discount!) + "% off  "
        }
        if model.deal?.type ==  "cashDiscount"{
            dealLabel.text = " " + typeCurrency + " " + String(model.deal!.cash_discount!) + " off  "
        }
        if model.deal?.type ==  "additionalProduct"{
            dealLabel.text = " Offer of " + String(model.deal!.base_amount! + model.deal!.additional_product!) + "x" + String(model.deal!.base_amount!) + "   "
        }
        if model.deal?.type == "percentageDiscountInLastProductAtQuantity"{
            dealLabel.text = " " + String(model.deal!.percentage_discount_at_quantity!) + "% off on " + String(model.deal!.quantity_products!) + "° product  "
        }
        
        dealLabel.backgroundColor = .colorPrimary
        dealLabel.textColor = .primaryTextColor
        
        updateView()
    }
    
    func presentBlankPage(){
        blankPage.backgroundColor = .white
        blankPage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blankPage)
        blankPage.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blankPage.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        blankPage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        blankPage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.bringSubviewToFront(blankPage)
    }
    
    //MARK:- Funtions
    func findTypeCurrency(){
        for product in model.deal?.products ?? []{
            self.typeCurrency = product.type_currency ?? ""
            return
        }
    }
    
    func applyDateFormat(dealDate:String) -> String{

        let isoDate0 = dealDate.replacingOccurrences(of: ".", with: "+")
        let isoDate = isoDate0.replacingOccurrences(of: "Z", with: "")
        
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from:isoDate)!
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MMMM-yyyy"
        let newdate = dateFormat.string(from: date)
        
        return newdate.replacingOccurrences(of: "-", with: " ")
    }
    
    func updateView(){
        findTypeCurrency()
        finalPriceLabel.text = "Final price with deal " + typeCurrency + " " + String(calculateFinalPrice())
        
        let n = calculateFinalPriceWithNoDeal()
        let str = "Final price with no deal " + (typeCurrency) + " " + String(n)
        let attributeString =  NSMutableAttributedString(string: str)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        finalPriceWithNoDealLabel.attributedText = attributeString
        finalPriceWithNoDealLabel.textColor = .lightGray
        
        enableButton()
    }
    
    func enableButton(){
        if isDealEnable() {
            applyDealBtn.setTitleColor(.primaryTextColor, for: .normal)
            applyDealBtn.backgroundColor = .colorPrimary
            applyDealBtn.isEnabled = true
        }else{
            applyDealBtn.setTitleColor(.white, for: .normal)
            applyDealBtn.backgroundColor = .lightGray
            applyDealBtn.isEnabled = false
        }
    }
    
    func isDealEnable()->Bool{
        for product in model.deal?.products ?? []{
            if product.quantity_shopping_cart == 0 && product.quantity != 0 {
                return true
            }
            if product.quantity_shopping_cart != 0 &&
               product.quantity != 0 &&
                product.quantity != product.quantity_shopping_cart{
                return true
            }
            if product.quantity_shopping_cart != 0 &&
               product.quantity == 0{
                return true
            }
        }
        return false
    }
    
    func extractRequestInformation(response: ResponseDeal){
        model.deal = response.data?.item
        for product in (model.deal?.products)!{
            product.quantity = product.quantity_shopping_cart
            if model.deal?.type ==  "additionalProduct"{
                product.quantity = product.quantity_shopping_cart! / ((model.deal?.base_amount)! + (model.deal?.additional_product)!)
            }
        }
    }
    func getUpdateDeals()->[Product]{
        var products:[Product] = []
        for product in model.deal?.products ?? []{
            if product.quantity_shopping_cart == 0 && product.quantity != 0 {
                products.append(product)
            }
            if product.quantity_shopping_cart != 0 &&
               product.quantity != 0 &&
                product.quantity != product.quantity_shopping_cart{
                products.append(product)
            }
            if product.quantity_shopping_cart != 0 &&
               product.quantity == 0{
                products.append(product)
            }
        }
        return products
    }
    
    func calculateQuantityProducts(product:Product)->Int{
        if product.quantity == 0 {return 0}
        if model.deal?.type ==  "additionalProduct"{
            return product.quantity! * ((model.deal?.base_amount)! + (model.deal?.additional_product)!)
        }
        return product.quantity!
    }
    
    func calculateQuantityDeals(product:Product)->Int{
        if model.deal?.type == "percentageDiscountInLastProductAtQuantity"{
            let n = product.quantity! % model.deal!.quantity_products!
            return (product.quantity! - n) / model.deal!.quantity_products!
        }
        return product.quantity!
    }
    
    func calculateFinalPrice()->Double{
        var n :Double = 0
        for product in model.deal?.products ?? []{
            n += (product.net_price! * Double(calculateQuantityDeals(product: product)))
            if model.deal?.type == "percentageDiscountInLastProductAtQuantity"{
                let m = product.quantity! % model.deal!.quantity_products!
                n += (Double(m) * product.price!)
            }
        }
        return n
    }
    
    func calculateFinalPriceWithNoDeal()->Double{
        var n :Double = 0
        for product in model.deal?.products ?? []{
            n += (product.price! * Double(calculateQuantityProducts(product: product)))
        }
        return n
    }
    
    func validateDeals(products:[Product])->Bool{
            for product in products{
                if product.quantity != 0{
                    var quantity = product.quantity!
                    let divisible = model.deal?.quantity_products
                    if quantity > divisible!{
                        quantity = quantity % divisible!
                        if quantity == 0 {quantity = divisible!}
                    }
                    if divisible! % quantity != 0 || quantity == 1{return false}
                }
                
            }
        
        return true
    }
    
    func fixDealValues(product:Product, quantityUp:Bool){
        if product.quantity != 0{
            var quantity = product.quantity!
            let divisible = model.deal?.quantity_products
            if quantity > divisible!{
                quantity = quantity % divisible!
                if quantity == 0 {quantity = divisible!}
            }
            if divisible! % quantity != 0 || quantity == 1{
                let falta = divisible! - quantity
                let sobra = divisible! - falta
                if quantityUp{
                    product.quantity! += falta
                }
                else{
                    product.quantity! -= sobra
                }
            }
        }
    }
    
    //MARK:-Visual event
    @IBAction func applyDeal(_ sender: Any) {
        let products = getUpdateDeals()
        if !products.isEmpty{
            if model.deal?.type == "percentageDiscountInLastProductAtQuantity" {
                if !validateDeals(products: products){
                    Alert.showDecitionAlert(
                    on: self,
                    with: "Products out of Deal",
                    message: "It seems to be products out of deal. Do you want to add products to take advanish of the deal",
                    acceptHandler: {
                        for product in self.model.deal?.products ?? []{
                            self.fixDealValues(product: product, quantityUp: true)
                        }
                        var str:String = "["
                        for product in products{
                            str += "{\"id\":" + String(product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals(product: product)) + "},"
                        }
                        str = String(str.prefix(str.count - 1))
                        str += "]"
                        print(str)
                        self.makeUpdateRequest(headers: [String((self.model.deal?.id)!)], method: "PUT",body: ["storeProducts": str])
                        self.navigationController?.popViewController(animated: true)
                        
                    },
                    cancelHandler: {
                        for product in self.model.deal?.products ?? []{
                            self.fixDealValues(product: product, quantityUp: false)
                        }
                        var str:String = "["
                        for product in products{
                            str += "{\"id\":" + String(product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals(product: product)) + "},"
                        }
                        str = String(str.prefix(str.count - 1))
                        str += "]"
                        print(str)
                        self.makeUpdateRequest(headers: [String((self.model.deal?.id)!)], method: "PUT",body: ["storeProducts": str])
                        self.navigationController?.popViewController(animated: true)
                        
                    })
                }
                else{
                    var str:String = "["
                    for product in products{
                        str += "{\"id\":" + String(product.store_product_id!) + ",\"quantity\":" + String(calculateQuantityDeals(product: product)) + "},"
                    }
                    str = String(str.prefix(str.count - 1))
                    str += "]"
                    print(str)
                    makeUpdateRequest(headers: [String((model.deal?.id)!)], method: "PUT",body: ["storeProducts": str])
                    navigationController?.popViewController(animated: true)
                }
            }
            else{
                var str:String = "["
                for product in products{
                    str += "{\"id\":" + String(product.store_product_id!) + ",\"quantity\":" + String(calculateQuantityDeals(product: product)) + "},"
                }
                str = String(str.prefix(str.count - 1))
                str += "]"
                print(str)
                makeUpdateRequest(headers: [String((model.deal?.id)!)], method: "PUT",body: ["storeProducts": str])
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK:- Request
    func makeRequest(){
        let request = RequestManager().getRequest(
            url: model.url,
            headers: [String((model.deal?.id)!)],
            params: [:],
            method: "GET")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
        if let data = data {
            do {
                let response = try JSONDecoder().decode(ResponseDeal.self, from: data)
                DispatchQueue.main.async {
                    self.extractRequestInformation(response: response)
                    self.configureTableView()
                    self.setView()
                    self.view.sendSubviewToBack(self.blankPage)
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
    
    func makeUpdateRequest(headers:[String],method:String,body:[String:String]){
        RequestManager().makeRequestWithBody(
            on: self,
            url: model.urlCart,
            headers: headers,
            params: [:],
            method: method,
            body: body,
            withSemaphore: true
        )
    }
}

//MARK:- Extensions
extension DealDetail: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.deal?.products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDealCell") as! ProductDealCell
        cell.dealType = model.deal?.type
        cell.updateView = {self.updateView()}
        cell.fullAmmount = {Alert.showBasicAlert(on: self, with: "Amount not allowed", message: "Maximum quantity allowed")}
        
        if model.deal?.type == "additionalProduct"{
            cell.base_amount = model.deal?.base_amount
            cell.additional_product = model.deal?.additional_product
        }
        if model.deal?.type == "percentageDiscountInLastProductAtQuantity"{
            cell.quantity_products = model.deal?.quantity_products
            cell.percentage_discount_at_quantity = model.deal?.percentage_discount_at_quantity
        }
        cell.setView(product: (model.deal?.products?[indexPath.row])!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeigth)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.model.deal?.products![indexPath.row].quantity_store_product != 0{
            performSegue(withIdentifier: "productItemSegue", sender:self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let destination = segue.destination as? ProductDetail {
            let product:Product! = model.deal?.products![indexPath!.row]
            destination.model.product = product
            destination.model.dealMode = true
            destination.model.editMode = product.quantity_shopping_cart != 0
            destination.model.deal_id = (model.deal?.id)!
            let type = model.deal?.type
            if type == "cashDiscount"{
                destination.model.dealType = type!
                destination.model.cash_discount = (model.deal?.cash_discount)!
            }
            if type == "percentageDiscount"{
                destination.model.dealType = type!
                destination.model.percentage_discount = (model.deal?.percentage_discount)!
            }
            if type == "additionalProduct"{
                destination.model.dealType = type!
                destination.model.additional_product = (model.deal?.additional_product)!
                destination.model.base_amount = (model.deal?.base_amount)!
            }
            if type == "percentageDiscountInLastProductAtQuantity"{
                destination.model.dealType = type!
                destination.model.quantity_products = (model.deal?.quantity_products)!
                destination.model.percentage_discount_at_quantity = (model.deal?.percentage_discount_at_quantity)!
            }
            destination.model.setFirstValues()
        }
    }
}

