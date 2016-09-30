//
//  FBNetworking.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/1/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


func taskForGetMethod(_ accessToken: String, completionHandlerForGet: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) {
    
    let url = "https://api.fitbit.com/1/user/-/profile.json"
    
    let requestType = "GET"
    let request = NSMutableURLRequest(url: URL(string: url)!)
    request.httpMethod = requestType
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    processRequest(request) { (result, error) in
        
        if error == nil {
            completionHandlerForGet(result, nil)
        } else {
            completionHandlerForGet(nil, error)
        }
    }
}

func taskForPostMethod(_ convertedAuthHeader: String, body: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void)   {

    let url = "https://api.fitbit.com/oauth2/token"
    
    let requestType = "POST"
    
    let request = NSMutableURLRequest(url: URL(string: url)!)
    request.httpMethod = requestType
    request.addValue("Basic \(convertedAuthHeader)", forHTTPHeaderField: "Authorization")
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpBody = body.data(using: String.Encoding.utf8)
    
    processRequest(request) { (result, error) in
        
        if error == nil {
            completionHandlerForPOST(result, nil)
        } else {
            completionHandlerForPOST(nil, error)
        }
    }
}

func processRequest(_ request: AnyObject, completionHandlerForProcessing: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) {
    
    if Reachability.isConnectedToNetwork() {

    let task = URLSession.shared.dataTask(with: request as! URLRequest, completionHandler: { (data, response, error) in

        func sendError(_ error: AnyObject) {
            print("error \(error)")
            completionHandlerForProcessing(nil, error)
        }

        guard (error == nil) else {
            sendError((error?.localizedDescription)! as AnyObject)
            return
        }

        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            
            sendError(((response as? HTTPURLResponse)!.statusCode as AnyObject))
            return
        }
 
        guard let data = data else {
            
            sendError("No data was returned by Fitbit" as AnyObject)
            return
        }
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        } catch {
            sendError("parsing Udacity Post method failed" as AnyObject)
        }
        completionHandlerForProcessing(parsedResult, nil)
    }) 
        
    task.resume()
        
    } else {
        
        completionHandlerForProcessing(nil, 001 as AnyObject?)
    }
}
