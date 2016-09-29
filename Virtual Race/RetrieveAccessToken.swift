//
//  practiceAuthorizationCode.swift
//  Virtual Tourist
//
//  Created by Christopher Weaver on 9/1/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation

class RetrieveAccessToken {
    
    func retrieveData(_ completionHandler: @escaping (_ success: Bool?, _ error: AnyObject?) -> Void) {
        
       let accessToken = UserDefaults.standard.object(forKey: "Access Token") as? String
        
        taskForGetMethod((accessToken)!) { (result, error) in
            
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    completionHandler(nil, 401 as AnyObject?)
                } else {
                    completionHandler(nil, error)
                }
                
                return
            }
            
            guard let user = result?["user"] as? [String:AnyObject] else {
                print("could not find user")
                return
            }
            
            guard let avatar = user["avatar"] as? String else {
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
            
            let convertedAvatar = try? Data(contentsOf: URL(string: avatar)!)
            let urlAvatar = URL(string: avatar)!
            
            UserDefaults.standard.set(convertedAvatar, forKey: "myAvatar")
            UserDefaults.standard.set(urlAvatar, forKey: "avatar")
            UserDefaults.standard.set(fullName, forKey: "fullName")
            UserDefaults.standard.set(encodedID, forKey: "myID")
            
            completionHandler(true, nil)
            
        }
    }
}
