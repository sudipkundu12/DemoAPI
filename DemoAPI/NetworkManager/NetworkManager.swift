//
//  NetworkManager.swift
//  XOOWEE
//
//  Created by Pace Wisdom on 23/09/18.
//  Copyright © 2018 Xoowee. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import SVProgressHUD

import enum Result.Result

class NetworkManager:NSObject {
    
    /// Shared Instance
    static let sharedInstance = NetworkManager()
    
    // MARK: - Local variables
    var providerWithToken: MoyaProvider<NetworkApiService>
    var provider: MoyaProvider<NetworkApiService>
    //var user:String

    /// Base Api Url
    var baseAPIUrl: String {
        #if DEBUG
        print("**** DEVELOPMENT ***")
        //return "http://ec2-35-170-249-153.compute-1.amazonaws.com/Api.Xoowee/api"
        return "http://varcharinfotech.com/api.xooWee/api"

       // return "http://ec2-184-73-43-21.compute-1.amazonaws.com/Api.xoowee/api"

      // return "http://ec2-54-163-0-98.compute-1.amazonaws.com/Api.xoowee/api"

        #else
        print("**** PRODUCTION ****")
        return "http://varcharinfotech.com/api.xooWee/api"
        //return "http://ec2-54-163-0-98.compute-1.amazonaws.com/Api.xoowee/api"

        #endif
    }
   
//https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json
    /// Closure is responsible for setting access token and any other parameters
    let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
        do {
            var request = try endpoint.urlRequest()
            print("**** Endpoint : \(String(describing: request.url))")
            
            if let token = UserDefaults.standard.value(forKey: "user_access_token") as? String {
                print("**** ACCESS TOKEN: \(token)")
                request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            // Modify the request however you like.
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error,nil)))
        }
    }
    // MARK: Init
    override init() {
        providerWithToken = MoyaProvider<NetworkApiService>(requestClosure:requestClosure)
        provider = MoyaProvider<NetworkApiService>()
    }
    
    // MARK: API Request Handling
    /// General API request method after logging in, used for most API calls. In some cases, the user needs to handle their own errors.
    static func request(target: NetworkApiService, success successCallback: @escaping (JSON) -> Void) {
        
        if shouldShowIndicator(endpoint: target.path) {
            SVProgressHUD.show()
        }
        sharedInstance.providerWithToken.request(target) { (result) in
            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let response):
                
                let jsonResponse = JSON(response.data)
                if response.statusCode >= 200 && response.statusCode <= 300 {
                    // Successful responses
                    
                    let data = jsonResponse["data"]
                    if jsonResponse["data"].count > 0 {
                        successCallback(data)
                    }
                    else {
                        successCallback(jsonResponse)
                    }
                    
                    
                } else {
                    if response.statusCode == 401 {
                        
                        // Authorization error, grab a new token and retry request
                        sharedInstance.getNewAccessToken {
                            request(target: target, success: { jsonResponse in
                                print("Successfully retried the request")
                                successCallback(jsonResponse)
                            })
                        }
                    }else if response.statusCode == 500 {
                        successCallback(jsonResponse)
                    }
                    else {
                        handleStatusCodeErrors(jsonResponse: jsonResponse, statusCode: response.statusCode, targetPath: target.path)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /// General API request method before logging in. In some cases, the user needs to handle their own errors.
    static func requestWithoutToken(target: NetworkApiService, success successCallback: @escaping (JSON) -> Void) {
        
        if shouldShowIndicator(endpoint: target.path) {
            SVProgressHUD.show()
        }
        sharedInstance.provider.request(target) { (result) in
            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let response):
                let jsonResponse = JSON(response.data)
                
                if response.statusCode >= 200 && response.statusCode <= 400 { // Success Responses
                    print("---- REQUEST SUCCESS ----\nPath: \(target.path) : STATUS CODE:\(response.statusCode)")
                    
                    //get accessToken
                    if let accessToken = response.response?.allHeaderFields["Access-Token"] as? String {
                        UserDefaults.standard.setValue(accessToken, forKey: "user_access_token")
                    }
                    
                    //trim status and send only contents of data.
                    let data = jsonResponse["data"]
                    if jsonResponse["data"].count > 0 {
                        successCallback(data)
                    }
                    else {
                        successCallback(jsonResponse)
                    }
                    
                }

                else {
                    handleStatusCodeErrors(jsonResponse: jsonResponse, statusCode: response.statusCode, targetPath: target.path)
                }
            case .failure( _): break

            }
        }
    }
    
    static func handleStatusCodeErrors(jsonResponse: JSON, statusCode: Int, targetPath: String) {
        
        print("---- REQUEST ERROR ----\nPath: \(targetPath) : STATUS CODE:\(statusCode) \nJSON Response: \(jsonResponse)")
        
        // If their access token expired, get a new one and retry the request
        if statusCode >= 500 {
            // Handle server errors
            if let errorNumCode = jsonResponse["error"]["numCode"].int {
                handleServerError(numCode: errorNumCode, path: targetPath)
            }
        } else if statusCode >= 400 { // Handle request errors
            let errorJson = jsonResponse["error"]
            handleRequestError(errorJson: errorJson, statusCode: statusCode, path: targetPath)
        } else {
            #if DEBUG
            print("DEVELOPMENT ERROR")
            print(jsonResponse)

//            AlertManager.sharedInstance.presentSimpleAlert(title: "Whoops!", message: "You messed up your code yo. Try to fix it soon.")
            #else
            print("PRODUCTION ERROR")
            #endif
        }
    }
    
    /// Handles 500 errors with an alert
    static func handleServerError(numCode: Int, path: String) {
        
        
        #if DEBUG
        print("DEVELOPMENT ERROR")
        //AlertManager.sharedInstance.presentSimpleAlert(title: "ERROR NUMCODE: \(numCode)", message: "")
        #else
        print("PRODUCTION ERROR")
        #endif
    }
    
    /// Handles 400 errors with an alert
    static func handleRequestError(errorJson: JSON, statusCode: Int, path: String) {
        
        // Log it to firebase event
        _ = errorJson["message"].string
        if statusCode == 401 {
            //AlertManager.sharedInstance.presentSimpleAlert(title: "Invalid Credentials", message: "Sorry! We couldn't find a user with that email address and password.")
        } else if statusCode == 422 {
            //AlertManager.sharedInstance.presentSimpleAlert(title: "Account Exists", message: "There is an account already associated with that email.")
        } else {
            #if DEBUG
            print("DEVELOPMENT error")
            // AlertManager.sharedInstance.presentSimpleAlert(title: "ERROR", message: errorMessage!)
            #else
            print("PRODUCTION")
            #endif
        }
    }
    
    func getNewAccessToken(completionHandler: @escaping() -> Void) {
        
    }
    
    // MARK: Login/Signup Handling
    
    /// Stores user information when they first login/signup
    func storeLogInDetails(jsonResponse: JSON) {
        let accessToken: String = (jsonResponse["access_token"]["id"]).string!
        UserDefaults.standard.setValue(accessToken, forKey: "user_access_token")
        let refreshToken: String = (jsonResponse["refresh_token"]["id"]).string!
        UserDefaults.standard.setValue(refreshToken, forKey: "user_refresh_token")
        
        let userJson: JSON = jsonResponse["user"]
        print(userJson)
        
        //Store user object
        //NetworkManager.sharedInstance.user = User(json: userJson)
    }
    
   
    
    // MARK: UI
    
    // Activity indicator whitelist
    // These endpoints will not display an indicator
    static func shouldShowIndicator(endpoint: String) -> Bool {
        return !(endpoint == "/users/me/getSpotList" || endpoint == "/users/me/updateLocation")
    }
    
    
    
}










