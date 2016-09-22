//
//  RetrieveFBFriends.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/7/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation



class retrieveFBFriends {
    
    func getFriends(completionHandler: (friendList: [[String:AnyObject]]?, error: AnyObject?) -> Void ) {
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("Access Token") as? String
        
        let url = "https://api.fitbit.com/1/user/-/friends.json"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        processRequest(request) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                
                completionHandler(friendList: nil, error: 401)
                    
                } else {
                    
                    completionHandler(friendList: nil, error: error)
                }
                
                return
            }

            guard let results = result else {
                return
            }
            
            guard let friends = results["friends"] as? [[String:AnyObject]] else {
                print("no friends list")
                return
            }
 
            completionHandler(friendList: friends, error: nil)
        }
    }
}