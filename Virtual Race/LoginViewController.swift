//
//  LoginViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/26/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import SafariServices


let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class LoginViewController: ViewControllerMethods, SFSafariViewControllerDelegate {
    
    let authURL = NSURL(string: "https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=227ST9&scope=activity%20profile%20social&expires_in=31536000&prompt=consent")
    
    var safariVC: SFSafariViewController!
    
    @IBAction func permitAccess(sender: AnyObject) {
        
        openSafari()
    }
    
    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "safariLogin:", name: kCloseSafariViewControllerNotification, object: nil)
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "refresh")
    }
    
    func openSafari() {
        
        safariVC = SFSafariViewController(URL: authURL!)
        
        self.presentViewController(safariVC!, animated: true, completion: nil)
        
    }
    
    func safariLogin(notification: NSNotification) {
        
        let url = notification.object as! NSURL
        
        let urlAuthorizationCode = String(url)
        
        let findStartingIndex = urlAuthorizationCode.rangeOfString("=")
        
        let startingIndex = findStartingIndex?.endIndex
        
        let modifiedURLAuthorizationCode = urlAuthorizationCode.substringFromIndex(startingIndex!)
        
        let findEndingIndex = modifiedURLAuthorizationCode.rangeOfString("&")
        
        let endingIndex = findEndingIndex?.startIndex
        
        let authorizationCode = modifiedURLAuthorizationCode.substringToIndex(endingIndex!)
        
        NSUserDefaults.standardUserDefaults().setObject(authorizationCode, forKey: "Access Token")
        
        let dataRet = RetrieveAccessToken()
        dataRet.retrieveData() { (success, error) in
            
            guard (error == nil) else {
                if error as? Int == 001 {
                    self.displayAlert("No internet connection")
                }else {
                    self.displayAlert("There was a problem accessing the fitbit servers, please try again later")
                }
                return
            }
            
            if (success != nil) {
                
                performUIUpdatesOnMain{
                    
                    self.dismissViewControllerAnimated(false, completion: nil)
                    
                    let controller: UINavigationController
                    controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
                    
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                }
            }
        }
    }
}