//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Christopher Weaver on 8/31/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import UIKit
import Foundation
import SafariServices
import CloudKit

let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class LoginWebViewController: UIViewController, SFSafariViewControllerDelegate {
    
    let authURL = NSURL(string: "https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=227ST9&scope=activity%20profile%20social&expires_in=31536000&prompt=consent")
    
    var safariVC: SFSafariViewController!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var userNameTextView: UITextView!
    
    @IBAction func logOut(sender: AnyObject) {
        
        let logOutAlert = UIAlertController(title: "Warning - You are about to log out of your fitbit account", message: "Virtual Race requires users to be logged into a fibit account through Virtual Race. By Logging out the user must log in again with a fitbit account to continue using the Virtual Race app", preferredStyle: UIAlertControllerStyle.Alert)
        
        logOutAlert.addAction(UIAlertAction(title: "log out", style: .Default, handler: { (action: UIAlertAction) in
            
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Access Token")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Refresh Token")
            
            self.viewDidAppear(false)
                
        }))
        
        logOutAlert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: { (action: UIAlertAction) in
            
        }))
        
        self.presentViewController(logOutAlert, animated: false, completion: nil)
        
    }
    
    @IBAction func startNewRace(sender: AnyObject) {
        
        let controller: UITabBarController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("RacesViewController") as! UITabBarController
        
        self.presentViewController(controller, animated: false, completion: nil)
        
    }
       
    @IBAction func getData(sender: AnyObject) {
        
        let controller: StartMatchViewController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("StartMatchViewController") as! StartMatchViewController
        
        self.presentViewController(controller, animated: false, completion: nil)
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
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
       NSNotificationCenter.defaultCenter().addObserver(self, selector: "safariLogin:", name: kCloseSafariViewControllerNotification, object: nil)

            if (NSUserDefaults.standardUserDefaults().objectForKey("Access Token") == nil) {
                
                let fitbitAlert = UIAlertController(title: "Virtual Race needs permission to access your Fitbit account", message: "Select the Permit Access button to authenticate your credentials.", preferredStyle: UIAlertControllerStyle.Alert)
                
                fitbitAlert.addAction(UIAlertAction(title: "Permit Access", style: .Default, handler: { (action: UIAlertAction!) in
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "refresh")
                        self.openSafari()
                    }))
                    
                fitbitAlert.addAction(UIAlertAction(title: "Exit App", style: .Cancel, handler: { (action: UIAlertAction!) in
                    exit(0)
                }))
                
                self.presentViewController(fitbitAlert, animated: true, completion: nil)

            } else {
               
                let avatarImage = NSUserDefaults.standardUserDefaults().objectForKey("myAvatar") as? NSData
                
                self.avatarImage.image = UIImage(data: avatarImage!)
                
                self.userNameTextView.text = NSUserDefaults.standardUserDefaults().objectForKey("fullName") as? String
              
            }
        }
    
    func displayAlert(text: String) {
        let networkAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        networkAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
            
        }))
        self.presentViewController(networkAlert, animated: true, completion: nil)
    }

}
