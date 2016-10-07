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
    
    @IBOutlet weak var startRaceButton: UIButton!
    
    @IBOutlet weak var userNameTextView: UITextView!
    
    @IBAction func logOut(_ sender: AnyObject) {
        
        let logOutAlert = UIAlertController(title: "Warning - You are about to log out of your fitbit account", message: "Virtual Race requires users to be logged into a fibit account through Virtual Race. By Logging out the user must log in again with a fitbit account to continue using the Virtual Race app", preferredStyle: UIAlertControllerStyle.alert)
        
        logOutAlert.addAction(UIAlertAction(title: "log out", style: .default, handler: { (action: UIAlertAction) in
            
            UserDefaults.standard.set(nil, forKey: "Access Token")
            
            let controller: LoginViewController
            controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(controller, animated: true, completion: nil)
            
        }))
        
        logOutAlert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        self.present(logOutAlert, animated: false, completion: nil)
        
    }
    
    @IBOutlet weak var raceRequestButton: UIButton!
    
    @IBAction func raceRequestsButton(_ sender: AnyObject) {
        
        let controller: RaceRequestsViewController
        controller = self.storyboard!.instantiateViewController(withIdentifier: "RaceRequestsViewController") as! RaceRequestsViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
            self.raceRequestButton.imageView?.image = UIImage(named: "Notification")
        
            if (UserDefaults.standard.object(forKey: "Access Token") == nil) {
                
                let controller: LoginViewController
                controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                
                self.present(controller, animated: true, completion: nil)

            } else {
                
                self.userNameTextView.text = UserDefaults.standard.object(forKey: "fullName") as? String
              
                checkRaceRequests()
            }
    }
    
    func checkRaceRequests() {
        
        let defaultContainer = CKContainer.default()
        
        let publicDB = defaultContainer.publicCloudDatabase
        
        let predicate1 = NSPredicate(format: "%K == %@", "oppID", (UserDefaults.standard.object(forKey: "myID") as? String!)!)
        
        let predicate2 = NSPredicate(format: "%K == %@", "started", "false")
        
        let predicate3 = NSPredicate(format: "%K == %@", "rejected", "false")
        
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1, predicate2, predicate3])
        
        let query = CKQuery(recordType: "match", predicate: andPredicate)
        
        if isICloudContainerAvailable() {
            
            publicDB.perform(query, inZoneWith: nil) {
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
