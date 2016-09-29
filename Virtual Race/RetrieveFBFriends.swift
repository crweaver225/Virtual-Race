//
//  RetrieveFBFriends.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/7/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation



class retrieveFBFriends {
    
    func getFriends(_ completionHandler: @escaping (_ friendList: [[String:AnyObject]]?, _ error: AnyObject?) -> Void ) {
        
        let accessToken = UserDefaults.standard.object(forKey: "Access Token") as? String
        
        let url = "https://api.fitbit.com/1/user/-/friends.json"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        processRequest(request) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                
                completionHandler(nil, 401 as AnyObject?)
                    
                } else {
                    
                    completionHandler(nil, error)
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
 
            completionHandler(friends, nil)
        }
    }
}
