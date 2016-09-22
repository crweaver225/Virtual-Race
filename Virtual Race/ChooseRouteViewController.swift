//
//  ChooseRouteViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/7/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class ChooseRouteViewController: UIViewController {
    
    var fetchedResultsController: NSFetchedResultsController!
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var oppName = String()
    
    var oppAvatar = NSData()
    
    var oppID = String()
    
    var oneDayfromNow: NSDate {
        
        let date = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: [])!
        return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func YorkvilletoOswego(sender: AnyObject) {
        chooseRace("1")
    }
    
    @IBAction func ShermansMarchTrail(sender: AnyObject) {
        chooseRace("2")
    }
    
    @IBAction func libertyTrail(sender: AnyObject) {
        chooseRace("3")
    }
    
    @IBAction func returnButton(sender: AnyObject) {
        
        let controller: UITabBarController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("RacesViewController") as! UITabBarController
        
        self.presentViewController(controller, animated: false, completion: nil)
    }
    

    func chooseRace(raceID: String) {
        
        if oppID == NSUserDefaults.standardUserDefaults().objectForKey("myID") as? String {
            
            let myID = NSUserDefaults.standardUserDefaults().objectForKey("myID") as! String
            
            let startMatchAlert = UIAlertController(title: "Confirm the Start of a New Match", message: "you new match against yourself will start at midnight on \(formatDate(oneDayfromNow))", preferredStyle: UIAlertControllerStyle.Alert)
            
            startMatchAlert.addAction(UIAlertAction(title: "Start the match!", style: .Default, handler: { (action: UIAlertAction!) in
                
                print("yyy \(self.oneDayfromNow)")
                
                let newMatch = Match(startDate: self.oneDayfromNow, myID: self.oppID, context: (self.delegate.stack?.context)!)
                newMatch.myAvatar = self.oppAvatar
                newMatch.myName = NSUserDefaults.standardUserDefaults().objectForKey("fullName") as? String
                newMatch.finished = false
                newMatch.started = true
                newMatch.raceLocation = raceID
                newMatch.finishDate = nil
                newMatch.winner = nil
                
                let onlineRace = CKRecord(recordType: "match")
                onlineRace["myID"] = myID
                onlineRace["oppID"] = nil
                onlineRace["d" + myID] = nil
                onlineRace["d" + self.oppID] = nil
                onlineRace["started"] = "true"
                onlineRace["finished"] = "false"
                onlineRace["startDate"] = self.oneDayfromNow
                onlineRace["finishDate"] = ""
                onlineRace["winner"] = ""
                onlineRace["raceLocation"] = raceID
                onlineRace["rejected"] = "false"

                let defaultContainer = CKContainer.defaultContainer()
                
                let publicDB = defaultContainer.publicCloudDatabase
                
                publicDB.saveRecord(onlineRace) { (record, error) -> Void in
                    guard let record = record else {
                        print("Error saving record: ", error)
                        return
                    }
                    
                    newMatch.recordID = record.recordID
                    
                    self.delegate.stack?.context.performBlock{
                        self.delegate.stack?.save()
                    }
                }
                
                self.delegate.stack?.context.performBlock{
                    self.delegate.stack?.save()
                }
                
                let controller: LoginWebViewController
                controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginWebViewController") as! LoginWebViewController
                
                self.navigationController?.pushViewController(controller, animated: true)
                
            }))
            
            startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(startMatchAlert, animated: true, completion: nil)
            
        } else {
            
            let myID = NSUserDefaults.standardUserDefaults().objectForKey("myID") as! String
            
            let startMatchAlert = UIAlertController(title: "Confirm the Start of a New Match", message: "Your new match against \(self.oppName) will start at midnight on \(formatDate(oneDayfromNow))", preferredStyle: UIAlertControllerStyle.Alert)
            startMatchAlert.addAction(UIAlertAction(title: "Start the match!", style: .Default, handler: { (action: UIAlertAction!) in
                
                performUIUpdatesOnMain{
                    self.activityIndicator.startAnimating()
                }
                
                print("yyy \(self.oneDayfromNow)")
                
                let newMatch = Match(startDate: self.oneDayfromNow, myID: myID, context: (self.delegate.stack?.context)!)
                newMatch.myName = NSUserDefaults.standardUserDefaults().objectForKey("fullName") as? String
                newMatch.myAvatar = NSUserDefaults.standardUserDefaults().objectForKey("myAvatar") as? NSData
                newMatch.oppID = self.oppID
                newMatch.oppName = self.oppName
                newMatch.oppAvatar = self.oppAvatar
                newMatch.finished = false
                newMatch.started = false
                newMatch.raceLocation = raceID
                newMatch.winner = nil
                newMatch.myFinishDate = nil
                newMatch.oppFinishDate = nil
    
                let onlineRace = CKRecord(recordType: "match")
                onlineRace["myID"] = myID
                onlineRace["oppID"] = self.oppID
                onlineRace["d" + myID] = 0.0
                onlineRace["d" + self.oppID] = 0.0
                onlineRace["u" + self.oppID] = self.oneDayfromNow
                onlineRace["u" + myID] = self.oneDayfromNow
                onlineRace["started"] = "false"
                onlineRace["finished"] = "false"
                onlineRace["startDate"] = self.oneDayfromNow
                onlineRace["myFinishDate"] = ""
                onlineRace["oppFinishDate"] = ""
                onlineRace["winner"] = ""
                onlineRace["raceLocation"] = raceID
                onlineRace["rejected"] = "false"
                
                let defaultContainer = CKContainer.defaultContainer()
                
                let publicDB = defaultContainer.publicCloudDatabase
                
                publicDB.saveRecord(onlineRace) { (record, error) -> Void in
                    guard let record = record else {
                        print("Error saving record: ", error)
                        return
                    }
                    
                    newMatch.recordID = record.recordID
                    
                    let controller: LoginWebViewController
                    controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginWebViewController") as! LoginWebViewController
                    
                    self.delegate.stack?.context.performBlock {
                        self.delegate.stack?.save()
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }))
            
            startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(startMatchAlert, animated: true, completion: nil)
        }
    }
}