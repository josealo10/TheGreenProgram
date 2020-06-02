//
//  RequestManager.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 3/18/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

class RequestManager{
    
    
    private func getURL(url:String , headers:[String], params:[String:String]) -> URL {
        var url = URL(string: url)
        
        for header in headers{
            url?.appendPathComponent(header)
        }
        if !params.isEmpty{
        var queryItems = [URLQueryItem]()
        for (key,value) in params{
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        url = url?.appendingParams(queryItems)
        }
        return url!
    }
    
    private func getBodyRequest(boundary: String, body:[String:String]) -> String{
        var parameters = [[String : Any]]()
        for (key,value) in body {
            let param = [
              "key": key,
              "value": value,
              "type": "text"
            ]
            parameters.append(param)
        }
        
        var body = ""
        for param in parameters {
          if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            let paramType = param["type"] as! String
            if paramType == "text" {
              let paramValue = param["value"] as! String
              body += "\r\n\r\n\(paramValue)\r\n"
            }
          }
        }
        body += "--\(boundary)--\r\n";
        
        return body
    }
    
    func getRequest(
        url:String,
        headers:[String],
        params:[String:String],
        method:String
    ) -> URLRequest
    {
        let url = getURL(url: url, headers: headers, params: params)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(AWS.getToken(), forHTTPHeaderField: "Authorization")
        return request
        
    }
    
    func getRequestWithBody(
        url:String,
        headers:[String],
        params:[String:String],
        method:String,
        body:[String:String]
    ) -> URLRequest
    {
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = getURL(url: url, headers: headers, params: params)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(AWS.getToken(), forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = getBodyRequest(boundary: boundary, body: body).data(using: .utf8)
        return request
        
    }
    
    func makeRequestWithBody(
        on vc: UIViewController,
        url:String,
        headers:[String],
        params:[String:String],
        method:String,
        body:[String:String],
        withSemaphore:Bool
        )
    {
        let semaphore = DispatchSemaphore(value: 0)
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = getRequest(url: url, headers: headers, params: params, method: method)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = getBodyRequest(boundary: boundary, body: body).data(using: .utf8)
        let session = URLSession.shared
        session.dataTask(with: request){ (data, response, error) in
            if let data = data{
                let str = String(data: data, encoding: .utf8)
                print(str)
                semaphore.signal()
            }
            if let error = error {
                Alert.showBasicAlert(on: vc, with: "Error", message: "\(error.localizedDescription)")
                semaphore.signal()
            }
        }.resume()
        if withSemaphore{
            semaphore.wait()
        }
    }
    
}
