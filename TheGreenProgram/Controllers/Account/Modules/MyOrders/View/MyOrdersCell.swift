//
//  MyOrdersCell.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/11/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import MapKit

class MyOrdersCell: UITableViewCell {
    
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var shippingPrice: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var addressDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var containerView: UIView!
    
    func setView(order:Order){
        storeName.text = order.store_name
        shippingPrice.text = String(order.shipping_price!)
        statusLabel.text = order.status
        addressNameLabel.text = order.shipping_address_details
        noteLabel.text = order.note
        totalPriceLabel.text = String(order.price!)
        storeImage.backgroundColor = .colorPrimary
        
        let location = CLLocationCoordinate2D(
            latitude: order.shipping_address_latitude!,
            longitude: order.shipping_address_longitude!)
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        
        background.backgroundColor = .colorBackground
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10.0
        containerView.layer.masksToBounds = false
        
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.8
    }
}
