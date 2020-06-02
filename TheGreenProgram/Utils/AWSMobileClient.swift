//
//  AWSMobileClient.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/20/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import Amplify
import AWSMobileClient
import AmplifyPlugins
import UIKit
class AWS {
    
    static func signIn(username: String, password: String) -> (Bool,String){
        let semaphore = DispatchSemaphore(value: 0)
        var flag = false
        var errorMessage = ""
            AWSMobileClient.default().signIn(username: username, password: password) { (signInResult, error) in
                if let error = error  {
                    flag = false
                    errorMessage = error.localizedDescription
                    semaphore.signal()
                } else if let signInResult = signInResult {
                    switch (signInResult.signInState) {
                    case .signedIn:
                        print("User is signed in.")
                        flag = true
                        semaphore.signal()
                    case .smsMFA:
                        print("SMS message sent to \(signInResult.codeDetails!.destination!)")
                        flag = true
                        semaphore.signal()
                    default:
                        flag = false
                        errorMessage = "Sign In needs info which is not et supported."
                        semaphore.signal()
                    }
                }
            }
        semaphore.wait()
        return (flag, errorMessage)
    }
    
    static func singUp (
        email:String,
        password:String,
        name:String,
        surname:String,
        birthdate:String,
        phone:String,
        address:String,
        gender:String,
        latitude:String,
        longitude:String
    ) -> (Bool,String)
    {
        var flag: Bool = false
        var errorMessage :String = ""
        let semaphore = DispatchSemaphore(value: 0)
        AWSMobileClient.default().signUp(
            username: email,
            password: password,
            userAttributes:
            ["name":name,
             "family_name": surname,
             "birthdate": birthdate,
             "phone_number": phone,
             "address":address,
             "gender":gender,
             "custom:latitude": latitude,
             "custom:longitude": longitude
            ])
        { (signUpResult, error) in
            if let signUpResult = signUpResult {
                switch(signUpResult.signUpConfirmationState) {
                case .confirmed:
                    print("User is signed up and confirmed.")
                    flag = true
                    semaphore.signal()
                case .unconfirmed:
                    print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
                    flag = true
                    semaphore.signal()
                case .unknown:
                    flag = true
                    semaphore.signal()
                    print("Unexpected case")
                }
            } else if let error = error {
                if let error = error as? AWSMobileClientError {
                    switch(error) {
                    case .usernameExists(let message):
                        print(message)
                        errorMessage = message
                        flag = false
                        semaphore.signal()
                    case .invalidParameter(let message):
                        print(message)
                        errorMessage = message
                        flag = false
                        semaphore.signal()
                    default:
                        flag = false
                        errorMessage = "Error occurred"
                        semaphore.signal()
                        break
                    }
                }else{
                    print("\(error.localizedDescription)")
                    flag = false
                    errorMessage = error.localizedDescription
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()
        return (flag,errorMessage)
    }
    
    static func reSendConfirmationCode(username:String)->(Bool,String){
        
        var flag = true
        var errorMessage = ""
        
        let semaphore = DispatchSemaphore(value: 0)
        
        AWSMobileClient.default().resendSignUpCode(username: username, completionHandler: { (result, error) in
            if let signUpResult = result {
                print("A verification code has been sent via \(signUpResult.codeDeliveryDetails!.deliveryMedium) at \(signUpResult.codeDeliveryDetails!.destination!)")
                flag = true
                semaphore.signal()
            } else if let error = error {
                print("\(error.localizedDescription)")
                flag = false
                errorMessage = error.localizedDescription
                semaphore.signal()
            }
            semaphore.signal()
        })
        
        semaphore.wait()
        return (flag,errorMessage)
    }
    
    static func requestCode(email:String)->(Bool,String){
        var flag = true
        var errorMessage = ""
        
        let semaphore = DispatchSemaphore(value: 0)
        
        AWSMobileClient.default().forgotPassword(username: email) { (forgotPasswordResult, error) in
            if let forgotPasswordResult = forgotPasswordResult {
                switch(forgotPasswordResult.forgotPasswordState) {
                case .confirmationCodeSent:
                    print("Confirmation code sent via \(forgotPasswordResult.codeDeliveryDetails!.deliveryMedium) to: \(forgotPasswordResult.codeDeliveryDetails!.destination!)")
                    flag = true
                    semaphore.signal()
                default:
                    print("Error: Invalid case.")
                    semaphore.signal()
                }
            } else if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                flag = false
                errorMessage = error.localizedDescription
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return(flag,errorMessage)
    }
    
    static func forgotPassword(email:String, newPassword:String, code:String)->(Bool,String){
        
        var flag = true
        var errorMessage = ""
        
        let semaphore = DispatchSemaphore(value: 0)
        
        AWSMobileClient.default().confirmForgotPassword(username: email, newPassword: newPassword, confirmationCode: code) { (forgotPasswordResult, error) in
            if let forgotPasswordResult = forgotPasswordResult {
                switch(forgotPasswordResult.forgotPasswordState) {
                case .done:
                    print("Password changed successfully")
                    flag = true
                    semaphore.signal()
                default:
                    print("Error: Could not change password.")
                    flag = false
                    errorMessage = "Error: Could not change password."
                    semaphore.signal()
                }
            } else if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                flag = false
                errorMessage = error.localizedDescription
                semaphore.signal()
            }
        }
        
        
        semaphore.wait()
        return(flag,errorMessage)
    }
    
    static func getToken() -> String{
        var token  = ""
        let semaphoreToken = DispatchSemaphore(value:0)
        AWSMobileClient.default().getTokens { (tokens, error) in
            if let error = error {
                print("Error getting token \(error.localizedDescription)")
                semaphoreToken.signal()
            } else if let tokens = tokens {
                token = "Bearer " + (tokens.idToken?.tokenString!)!
                print("TOKEN ID: ",token)
                semaphoreToken.signal()
            }
        }
        semaphoreToken.wait()
        return token
    }
    
    static func setUserAttributes(values: [String:String]){
        AWSMobileClient.default().updateUserAttributes(attributeMap: values){ result, error in
        guard error == nil else {
            print("Received un-expected error: \(error.debugDescription)")
            return
        }
            guard result != nil else {
            print("updateUserAttributes result unexpectedly nil")
            return
        }

        }
        
        for (key,value) in values{
            switch key {
            case "name":
                Profile.name = value
            case "family_name":
                Profile.surname = value
            default:
                break
            }
        }
    }
    
    static func changePassword(newPassword:String){
        AWSMobileClient.default().signIn(username: Profile.email, password: "Abc123!@") { (signInResult, error) in
            if let signInResult = signInResult {
                switch(signInResult.signInState) {
                case .signedIn:
                    print("User signed in successfully.")
                case .smsMFA:
                    print("Code was sent via SMS to \(signInResult.codeDetails!.destination!)")
                case .newPasswordRequired:
                    print("A change of password is needed. Please provide a new password.")
                default:
                    print("Other signIn state: \(signInResult.signInState)")
                }
            } else if let error = error {
                print("Error occurred: \(error.localizedDescription)")
            }
        }

        AWSMobileClient.default().confirmSignIn(challengeResponse: newPassword) { (signInResult, error) in
            if let signInResult = signInResult {
                switch(signInResult.signInState) {
                case .signedIn:
                    print("User signed in successfully.")
                case .smsMFA:
                    print("Code was sent via SMS to \(signInResult.codeDetails!.destination!)")
                default:
                    print("Other signIn state: \(signInResult.signInState)")
                }
            } else if let error = error {
                print("Error occurred: \(error.localizedDescription)")
            }
        }
    }
    
    static func downloadS3Data(key: String) {
        let semaphore = DispatchSemaphore(value:0)
        Amplify.Storage.getURL(key: key) { (event) in
            switch event {
            case .completed(let data):
                print("Completed: \(data)")
                semaphore.signal()
            case .failed(let storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                semaphore.signal()
            default:
                break
            }
        }
        semaphore.wait()
    }
}
