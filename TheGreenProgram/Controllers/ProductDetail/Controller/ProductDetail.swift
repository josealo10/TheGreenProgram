//
//  ProductDetail.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/29/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import ImageSlideshow

class ProductDetail: UIViewController {

    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    
    @IBOutlet weak var totalPriceWithNoDeal: UILabel!
    @IBOutlet weak var unitPrice: UILabel!
    @IBOutlet weak var unitMeasurement: UILabel!
    @IBOutlet weak var dealLabel: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var plus_button: UIButton!
    @IBOutlet weak var minus_button: UIButton!
    @IBOutlet weak var add_to_cart_btn: UIButton!
    @IBOutlet weak var favoriteBTN: UIButton!
    @IBOutlet weak var removeItemBTN: UIButton!
    var favoriteFlag:Bool = false
    
    var model = ProductDetailModel()
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigation()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if favoriteFlag {
            RequestManager().makeRequestWithBody(on: self, url: "https://thegreenmarket.tk/api/wish-list", headers: [], params: [:], method: "POST", body: ["product": String(model.product.product_id!)], withSemaphore: false)
        }else{
            
        }
    }
    
    //MARK:- Configuration
    func configureNavigation(){
        navigationItem.title = model.product.name
        navigationController?.navigationBar.tintColor = .primaryTextColor
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func configureView(){
        asignLabelsValues()
        configureImageSlider()
        
        dealLabel.backgroundColor = .colorPrimary
        dealLabel.textColor = .primaryTextColor
        
        plus_button.backgroundColor = .colorPrimary
        plus_button.setTitleColor(.primaryTextColor, for: .normal)
        plus_button.layer.cornerRadius = 11
        plus_button.clipsToBounds = true
        
        minus_button.backgroundColor = .colorPrimary
        minus_button.setTitleColor(.primaryTextColor, for: .normal)
        minus_button.layer.cornerRadius = 11
        minus_button.clipsToBounds = true
        
        add_to_cart_btn.backgroundColor = .colorPrimary
        add_to_cart_btn.setTitleColor(.primaryTextColor, for: .normal)
    }
    
    func configureImageSlider(){
        imageSlideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill

        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        imageSlideShow.pageIndicator = pageControl
        
        var images = [InputSource]()
        for image in model.product.images ?? []{
            images.append(
                SDWebImageSource(
                    urlString: image,
                    placeholder: UIImage(named: "no_image")) ?? ImageSource(image: UIImage(named: "no_image")!)
            )
        }
        imageSlideShow.setImageInputs(images)
        
        self.imageSlideShow.zoomEnabled = true
    }
    
    //MARK:- Functons
    func asignLabelsValues(){
        dealLabel.text = ""
        totalPriceWithNoDeal.text = ""
        removeItemBTN.setTitle("", for: .normal)
        removeItemBTN.isEnabled = false
        
        if model.dealMode{asignDealsLabels()}
        
        if model.editMode{
            add_to_cart_btn.setTitle("Update cart", for: .normal)
            removeItemBTN.setTitle("Remove item from cart", for: .normal)
            removeItemBTN.isEnabled = true
        }else{
            add_to_cart_btn.setTitle("Add to cart", for: .normal)
        }
        
        name.text = model.product.name
        des.text = model.product.description
        
        totalPrice.text = model.product.type_currency! + " " + String(calculateFinalPrice())
        unitPrice.text = model.product.type_currency! + String(model.product.price!)
        
        quantity.text = String(model.product.quantity!)
        unitMeasurement.text = (model.product?.unit_measurement)!
    }
    
    func asignDealsLabels(){
        if model.dealType == "percentageDiscount"{
            dealLabel.text = " " + String(model.percentage_discount) + "% off  "
        }
        if model.dealType ==  "cashDiscount"{
            dealLabel.text = " " + (model.product.type_currency)! + " " + String(model.cash_discount) + " off  "
        }
        if model.dealType ==  "additionalProduct"{
            dealLabel.text = " Offer of " + String(model.base_amount + model.additional_product) + "x" + String(model.base_amount) + "   "
        }
        if model.dealType == "percentageDiscountInLastProductAtQuantity"{
            dealLabel.text = " " + String(model.percentage_discount_at_quantity) + "% off on " + String(model.quantity_products) + "° product  "
        }
        
        let n = model.product.price! * Double(calculateQuantityProducts())
        let str = (model.product?.type_currency ?? "") + " " + String(n)
        let attributeString =  NSMutableAttributedString(string: str)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        totalPriceWithNoDeal.attributedText = attributeString
        totalPriceWithNoDeal.textColor = .lightGray
    }
    func calculateQuantityProducts()->Int{
        if model.product.quantity! == 0 {return 0}
        if model.dealType ==  "additionalProduct"{
            return model.product.quantity! * (model.base_amount + model.additional_product)
        }
        return model.product.quantity!
    }
    func calculateQuantityDeals()->Int{
        if model.product.quantity! == 0 {return 0}
        if model.dealType == "percentageDiscountInLastProductAtQuantity"{
            let n = model.product.quantity! % model.quantity_products
            return (model.product.quantity! - n) / model.quantity_products
        }
        return model.product.quantity!
    }
    
    func calculateFinalPrice()->Double{
        if model.dealMode{
            if model.dealType == "percentageDiscountInLastProductAtQuantity"{
                let n = Double(model.product.quantity! % model.quantity_products) * model.product.price!
                return (model.product?.net_price)! * Double(calculateQuantityDeals()) + n
            }
            return (model.product?.net_price)! * Double(calculateQuantityDeals())
        }
        return (model.product?.price)! * Double(model.product!.quantity!)
    }
    
    func isAcceptablePlus()->Bool{
        if model.dealMode{
            if model.dealType == "additionalProduct"{
                return model.product.quantity_store_product! >= (model.product.quantity! + 1) * (model.base_amount + model.additional_product)
            }
        }
        return model.product.quantity_store_product! >= model.product.quantity! + 1
    }
    
    func isAcceptableMinus()->Bool{
        if model.editMode{ return model.product.quantity! - 1 >= 0 }
        return model.product.quantity! - 1 > 0
    }
    
    //MARK:- Requests
    func makeRequest(method:String, headers : [String], body:[String:String]){
        RequestManager().makeRequestWithBody(
            on:self,
            url: model.url,
            headers: headers,
            params: [:],
            method: method,
            body: body,
            withSemaphore: true
        )
        model.product.quantity_shopping_cart = model.product.quantity
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Visual events
    @IBAction func plus(_ sender: Any){
        if isAcceptablePlus(){
            model.product.quantity! += 1
            asignLabelsValues()
            if model.product.quantity != 0 {add_to_cart_btn.backgroundColor = .colorPrimary}
        }else{
            Alert.showBasicAlert(on: self, with: "Maximum amount allowed", message: "There are not enough products in our inventory")
        }
    }
    
    @IBAction func minus(_ sender: Any){
        if isAcceptableMinus(){
            model.product.quantity! -= 1
            asignLabelsValues()
        }
    }
        
    @IBAction func favoritesPress(_ sender: Any) {
        favoriteFlag = !favoriteFlag
        if favoriteFlag{
            favoriteBTN.setBackgroundImage(UIImage(systemName: "heart.fill"),for: .normal)
        }else{
            favoriteBTN.setBackgroundImage(UIImage(systemName: "heart"),for: .normal)
        }
    }
    
    @IBAction func addToCart(_ sender: Any) {
        var method = ""
        var headers : [String] = []
        var body:[String:String] = [:]
        
        if model.editMode{
            if model.dealMode{
                if model.dealType == "percentageDiscountInLastProductAtQuantity" && model.product.quantity != 0{
                    var quantity = model.product.quantity!
                    let divisible = model.quantity_products
                    if quantity > divisible{
                        quantity = quantity % divisible
                        if quantity == 0 {quantity = divisible}
                    }
                    if divisible % quantity != 0 || quantity == 1{
                        let falta = divisible - quantity
                        let sobra = divisible - falta
                        Alert.showDecitionAlert(
                            on: self,
                            with: "Products out of Deal",
                            message: "It seems to be " + String(sobra) + " products out of deal. Do you want to add " + String(falta) + " products to take advanish of the deal",
                            acceptHandler: {
                                self.model.product.quantity! += falta
                                method = "PUT"
                                headers = ["deals",String(self.model.deal_id)]
                                body = ["storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                                self.makeRequest(method: method, headers: headers, body: body)
                            },
                            cancelHandler: {
                                self.model.product.quantity! -= sobra
                                method = "PUT"
                                headers = ["deals",String(self.model.deal_id)]
                                body = ["storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                                self.makeRequest(method: method, headers: headers, body: body)
                            })
                    }
                    else{
                        method = "PUT"
                        headers = ["deals",String(self.model.deal_id)]
                        body = ["storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                        self.makeRequest(method: method, headers: headers, body: body)
                    }
                }
                else{
                    method = "PUT"
                    headers = ["deals",String(self.model.deal_id)]
                    body = ["storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                    self.makeRequest(method: method, headers: headers, body: body)
                }
                
            }
            else{
                headers = ["products", String(model.product.store_product_id!)]
                if model.product.quantity == 0{
                    method = "DELETE"
                }
                else{
                    method = "PUT"
                    body = [
                        "storeProduct": String(model.product.store_product_id!),
                        "quantity": String(model.product.quantity!)
                    ]
                }
                makeRequest(method: method, headers: headers, body: body)
            }
        }
        else{
            method = "POST"
            if model.dealMode{
                if model.dealType == "percentageDiscountInLastProductAtQuantity" && model.product.quantity != 0{
                    var quantity = model.product.quantity!
                    let divisible = model.quantity_products
                    if quantity > divisible{
                        quantity = quantity % divisible
                        if quantity == 0 {quantity = divisible}
                    }
                    if divisible % quantity != 0 || quantity == 1{
                        let falta = divisible - quantity
                        let sobra = divisible - falta
                        Alert.showDecitionAlert(
                            on: self,
                            with: "Products out of Deal",
                            message: "It seems to be " + String(sobra) + " products out of deal. Do you want to add " + String(falta) + " products to take advanish of the deal",
                            acceptHandler: {
                                self.model.product.quantity! += falta
                                headers = ["deals"]
                                body = ["deal": String(self.model.deal_id),
                                        "storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                                self.makeRequest(method: method, headers: headers, body: body)
                            },
                            cancelHandler: {
                                self.model.product.quantity! -= sobra
                                headers = ["deals"]
                                body = ["deal": String(self.model.deal_id),
                                        "storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                                self.makeRequest(method: method, headers: headers, body: body)
                            })
                    }
                    else{
                        headers = ["deals"]
                        body = ["deal": String(self.model.deal_id),
                        "storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                        self.makeRequest(method: method, headers: headers, body: body)
                    }
                }
                else{
                    headers = ["deals"]
                    body = ["deal": String(self.model.deal_id),
                    "storeProducts":"[{\"id\":" + String(self.model.product.store_product_id!) + ",\"quantity\":" + String(self.calculateQuantityDeals()) + "}]"]
                    self.makeRequest(method: method, headers: headers, body: body)
                }
                
            }
            else{
                headers = ["products"]
                body = [
                    "storeProduct": String(model.product.store_product_id!),
                    "quantity": String(model.product.quantity!)
                ]
                makeRequest(method: method, headers: headers, body: body)
            }
        }
        
        
        
        
    }
    
    @IBAction func removeItem(_ sender: Any) {
        var headers : [String] = []
        var body:[String:String] = [:]
        var method: String = ""
        if model.dealMode{
            method = "PUT"
            headers = ["deals", String(model.deal_id)]
            body = ["deal": String(model.deal_id),
            "storeProducts":"[{\"id\":" + String(model.product.store_product_id!) + ",\"quantity\":0}]"]
        }
        else{
            method = "DELETE"
            headers = ["products", String(model.product.store_product_id!)]
        }
        
        RequestManager().makeRequestWithBody(
            on:self,
            url: model.url,
            headers: headers,
            params: [:],
            method: method,
            body: body,
            withSemaphore: true
        )
        model.product.quantity_shopping_cart = 0
        model.product.quantity = 0
        navigationController?.popViewController(animated: true)
    }
    
}
