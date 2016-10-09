//
//  RetrieveFBDistance.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/6/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

class RetrieveDistance {
    
    func getFinishDate(_ distance: Double, date: String, completionHandler: @escaping (_ result: String?, _ error: AnyObject?) -> Void) {
        
        var tempDistance = 0.0
        
        let accessToken = UserDefaults.standard.object(forKey: "Access Token") as? String
        
        let url = "https://api.fitbit.com/1/user/-/activities/tracker/distance/date/\(date)/today.json"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        request.addValue("en_US", forHTTPHeaderField: "Accept-Language")
        
        processRequest(request) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    completionHandler(nil, 401 as AnyObject?)
                    
                } else {
                    
                    completionHandler(nil, error)
                }
                
                return
            }

            guard let dates = result?["activities-tracker-distance"] as? [[String: AnyObject]] else {
                
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
                    completionHandler(fbDate, nil)
                    break
                }
            }
        }
    }
    
    
    func getDistance(_ date: String,  completionHandler: @escaping (_ result: Double?, _ error: AnyObject?) -> Void) {
        
        let accessToken = UserDefaults.standard.object(forKey: "Access Token") as? String
        
        var distance = 0.0
        
       let url = "https://api.fitbit.com/1/user/-/activities/tracker/distance/date/\(date)/today.json"

        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        request.addValue("en_US", forHTTPHeaderField: "Accept-Language")
        
        processRequest(request) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    completionHandler(nil, 401 as AnyObject?)
                    
                } else {
                    
                    completionHandler(nil, error)
                }
                
                return
            }
        
            guard let dates = result?["activities-tracker-distance"] as? [[String: AnyObject]] else {
                
                completionHandler(0.0, nil)
                
                return
            }
            
            
            for i in dates {
                
                guard let fbDistance = i["value"] as? String else {
                    
                    return
                }
                
                distance += Double(fbDistance)!
            }
            
            completionHandler(distance, nil)
            
        }
    }
}
