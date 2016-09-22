//
//  FBNetworking.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/1/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


func taskForGetMethod(accessToken: String, completionHandlerForGet: (result: AnyObject!, error: AnyObject?) -> Void) {
    
    let url = "https://api.fitbit.com/1/user/-/profile.json"
    
    let requestType = "GET"
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.HTTPMethod = requestType
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    processRequest(request) { (result, error) in
        
        if error == nil {
            completionHandlerForGet(result: result, error: nil)
        } else {
            completionHandlerForGet(result: nil, error: error)
        }
    }
}

func taskForPostMethod(convertedAuthHeader: String, body: String, completionHandlerForPOST: (result: AnyObject!, error: AnyObject?) -> Void)   {

    let url = "https://api.fitbit.com/oauth2/token"
    
    let requestType = "POST"
    
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.HTTPMethod = requestType
    request.addValue("Basic \(convertedAuthHeader)", forHTTPHeaderField: "Authorization")
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    
    processRequest(request) { (result, error) in
        
        if error == nil {
            completionHandlerForPOST(result: result, error: nil)
        } else {
            completionHandlerForPOST(result: nil, error: error)
        }
    }
}

func processRequest(request: AnyObject, completionHandlerForProcessing: (result: AnyObject!, error: AnyObject?) -> Void) {
    
    if Reachability.isConnectedToNetwork() {

    let task = NSURLSession.sharedSession().dataTaskWithRequest(request as! NSURLRequest) { (data, response, error) in

        func sendError(error: AnyObject) {
            print("error \(error)")
            completionHandlerForProcessing(result: nil, error: error)
        }

        guard (error == nil) else {
            sendError((error?.localizedDescription)!)
            return
        }

        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            
            sendError(((response as? NSHTTPURLResponse)!.statusCode))
            return
        }
 
        guard let data = data else {
            
            sendError("No data was returned by Fitbit")
            return
        }
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            sendError("parsing Udacity Post method failed")
        }
        completionHandlerForProcessing(result: parsedResult, error: nil)
    }
        
    task.resume()
        
    } else {
        
        completionHandlerForProcessing(result: nil, error: 001)
    }
}
