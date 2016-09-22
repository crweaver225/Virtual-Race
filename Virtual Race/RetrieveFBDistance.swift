//
//  RetrieveFBDistance.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/6/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

class RetrieveDistance {
    
    func getFinishDate(distance: Double, date: String, completionHandler: (result: String?, error: AnyObject?) -> Void) {
        
        var tempDistance = 0.0
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("Access Token") as? String
        
        let url = "https://api.fitbit.com/1/user/-/activities/tracker/distance/date/\(date)/today.json"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        request.addValue("en_US", forHTTPHeaderField: "Accept-Language")
        
        processRequest(request) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    completionHandler(result: nil, error: 401)
                    
                } else {
                    
                    completionHandler(result: nil, error: error)
                }
                
                return
            }

            guard let dates = result["activities-tracker-distance"] as? [[String: AnyObject]] else {
                
                return
            }
            
            for date in dates {
                
                guard let fbDistance = date["value"] as? String else {
                    print("no value")
                    return
                }
                guard let fbDate = date["dateTime"] as? String else {
                    print("no date")
                    return
                }
                
                tempDistance += Double(fbDistance)!
                
                if tempDistance >= distance {
                    completionHandler(result: fbDate, error: nil)
                    break
                }
            }
        }
    }
    
    
    func getDistance(date: String,  completionHandler: (result: Double?, error: AnyObject?) -> Void) {
        
        print("get distance")
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("Access Token") as? String
        
        var distance = 0.0
        
        let url = "https://api.fitbit.com/1/user/-/activities/tracker/distance/date/\(date)/today.json"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        request.addValue("en_US", forHTTPHeaderField: "Accept-Language")
        
        processRequest(request) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    completionHandler(result: nil, error: 401)
                    
                } else {
                    
                    completionHandler(result: nil, error: error)
                }
                
                return
            }
        
            guard let dates = result["activities-tracker-distance"] as? [[String: AnyObject]] else {
                
                completionHandler(result: 0.0, error: nil)
                return
            }
            
            
            for i in dates {
                guard let fbDistance = i["value"] as? String else {
                    
                    return
                }
                
                distance += Double(fbDistance)!
            }
            
            completionHandler(result: distance, error: nil)
            
        }
    }
}