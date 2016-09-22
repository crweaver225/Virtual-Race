//
//  practiceAuthorizationCode.swift
//  Virtual Tourist
//
//  Created by Christopher Weaver on 9/1/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

class RetrieveAccessToken {
    
    func retrieveData(completionHandler: (success: Bool?, error: AnyObject?) -> Void) {
        
       let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("Access Token") as? String
        
        taskForGetMethod((accessToken)!) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    print("need refresh token")
                    completionHandler(success: nil, error: 401)
                } else {
                    print("the error was \(error)")
                    completionHandler(success: nil, error: error)
                }
                
                return
            }
            
            guard let user = result["user"] as? [String:AnyObject] else {
                print("could not find user")
                return
            }
            
            guard let avatar = user["avatar150"] as? String else {
                print("could not find avatar")
                return
            }
            
            guard let fullName = user["fullName"] as? String else {
                print("could not find name")
                return
            }
                
            guard let encodedID = user["encodedId"] as? String else {
                print("no encoded ID")
                return
            }
            
            let convertedAvatar = NSData(contentsOfURL: NSURL(string: avatar)!)
            
            NSUserDefaults.standardUserDefaults().setObject(convertedAvatar, forKey: "myAvatar")
            NSUserDefaults.standardUserDefaults().setURL(NSURL(string:avatar), forKey: "avatar")
            NSUserDefaults.standardUserDefaults().setObject(fullName, forKey: "fullName")
            NSUserDefaults.standardUserDefaults().setObject(encodedID, forKey: "myID")
            
            completionHandler(success: true, error: nil)
            
        }
    }
}