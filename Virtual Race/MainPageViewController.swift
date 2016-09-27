//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Christopher Weaver on 8/31/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import UIKit
import Foundation
import CloudKit


class MainPageViewController: ViewControllerMethods {
    
    @IBOutlet weak var userNameTextView: UITextView!
    
    @IBAction func logOut(sender: AnyObject) {
        
        let logOutAlert = UIAlertController(title: "Warning - You are about to log out of your fitbit account", message: "Virtual Race requires users to be logged into a fibit account through Virtual Race. By Logging out the user must log in again with a fitbit account to continue using the Virtual Race app", preferredStyle: UIAlertControllerStyle.Alert)
        
        logOutAlert.addAction(UIAlertAction(title: "log out", style: .Default, handler: { (action: UIAlertAction) in
            
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Access Token")
            
            let controller: LoginViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        }))
        
        logOutAlert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(logOutAlert, animated: false, completion: nil)
        
    }
    
    @IBOutlet weak var raceRequestButton: UIButton!
    
    @IBAction func raceRequestsButton(sender: AnyObject) {
        
        let controller: UITabBarController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("RacesViewController") as! UITabBarController
        controller.selectedIndex = 1
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
            if (NSUserDefaults.standardUserDefaults().objectForKey("Access Token") == nil) {
                
                let controller: LoginViewController
                controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                
                self.presentViewController(controller, animated: true, completion: nil)

            } else {
                
                self.userNameTextView.text = NSUserDefaults.standardUserDefaults().objectForKey("fullName") as? String
              
                checkRaceRequests()
            }
    }
    
    func checkRaceRequests() {
        
        let defaultContainer = CKContainer.defaultContainer()
        
        let publicDB = defaultContainer.publicCloudDatabase
        
        let predicate1 = NSPredicate(format: "%K == %@", "oppID", (NSUserDefaults.standardUserDefaults().objectForKey("myID") as? String!)!)
        
        let predicate2 = NSPredicate(format: "%K == %@", "started", "false")
        
        let predicate3 = NSPredicate(format: "%K == %@", "rejected", "false")
        
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate1, predicate2, predicate3])
        
        let query = CKQuery(recordType: "match", predicate: andPredicate)
        
        if isICloudContainerAvailable() {
            
            publicDB.performQuery(query, inZoneWithID: nil) {
                (records, error) -> Void in
                guard let records = records else {
                    print("Error querying records: ", error)
                    return
                }
                
                if records.count > 0 {
                    
                    performUIUpdatesOnMain{
                        self.raceRequestButton.imageView?.image = UIImage(named: "Notification_Exists")
                    }
                }
            }
        }
    }
}
