//
//  ResponsesStructs.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 4/12/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
struct LoyaltyPointsResponse:Decodable{
    let current_points: Int?
    let total_points: Int?
}
struct LoyaltyLevelResponse:Decodable{
    let id: Int?
}
struct ProfileResponse:Decodable{
    let id: Int?
    let email: String?
    let name: String?
    let lastname: String?
    let gender: String?
    let address: String?
    let phone_number: String?
    let date_birth: String?
    let longitude: Double?
    let latitude: Double?
    let loyaltyLevel: LoyaltyLevelResponse?
    let loyaltyPoints: LoyaltyPointsResponse?
}
struct AccountItem:Decodable{
    let item: ProfileResponse?
}
struct AccountResponse:Decodable{
    let success: Bool?
    let data: AccountItem?
}

struct GeoResults:Decodable {
    let formatted_address:String?
}
struct GeoResponse:Decodable {
    let results:[GeoResults]?
}

struct LocationResponse:Decodable {
    let success:Bool?
}


struct DataDeal:Decodable{
    let item: Deal?
}

struct ResponseDeal:Decodable{
    let success:Bool?
    let data: DataDeal?
}


struct  DataDeals:Decodable{
    let quantity:Int?
    let items:[Deal]?
    let customer_in_range:Bool?
}

struct ResponseDeals: Decodable{
    let success: Bool?
    let data: DataDeals?
}


struct cartItem: Decodable {
    var store: Store
}

struct cartItems:Decodable {
    var items:[cartItem]?
}

struct ResponseCart:Decodable {
    var success: Bool?
    var data:cartItems?
}


struct  Data:Decodable{
    let quantity:Int?
    let items:[Product]?
}

struct Response: Decodable{
    let success: Bool?
    let data: Data?
}



struct dataCategories: Decodable{
    let items: [Category]?
}

struct ResponseCategories: Decodable {
    let success: Bool?
    let data: dataCategories?
}



struct LoyaltyData:Decodable{
    let quantity:Int?
    let items:[LoyaltyLevel]?
}
struct LoyaltyResponse:Decodable{
    let success: Bool?
    let data: LoyaltyData?
}



struct HomeItems:Decodable{
    let mostSoldProducts:[Product]?
    let lastestProducts:[Product]?
    let deals:[Deal]?
}

struct HomeData:Decodable{
    let items:[HomeItems]?
    let customer_in_range:Bool?
}

struct HomeResponse:Decodable{
    let success: Bool?
    let data: HomeData?
}

struct ResponseMakeOrder:Decodable{
    let success: Bool?
}

struct OrderData:Decodable{
    let items:[Order]?
}

struct ResponseOrder:Decodable {
    let success:Bool?
    let data: OrderData?
}

struct OrderDetailData:Decodable{
    let item:Order?
}

struct ResponseOrderDetail:Decodable {
    let success:Bool?
    let data: OrderDetailData?
}

struct WishListData:Decodable{
    let items:[Product]?
}
struct ResponseWishList:Decodable{
    let success:Bool?
    let data: WishListData?
}
