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

class ChooseRouteViewController: ViewControllerMethods {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func nyToLA(_ sender: AnyObject) {
        chooseRace("1")
    }
    
    @IBAction func crossTownClassic(_ sender: AnyObject) {
        chooseRace("2")
    }
    
    @IBAction func libertyTrail(_ sender: AnyObject) {
        chooseRace("3")
    }
    
    @IBAction func returnButton(_ sender: AnyObject) {
        
        let controller: UITabBarController
        controller = self.storyboard!.instantiateViewController(withIdentifier: "RacesViewController") as! UITabBarController
        
        self.present(controller, animated: false, completion: nil)
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var oppName = String()
    
    var oppAvatar = Data()
    
    var oppID = String()
    
    var oneDayfromNow: Date {
        
        let date = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: Date(), options: [])!
        return (Calendar.current as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: date, options: NSCalendar.Options())!
    }

    func chooseRace(_ raceID: String) {
        
        if oppID == UserDefaults.standard.object(forKey: "myID") as? String {
            
            let myID = UserDefaults.standard.object(forKey: "myID") as! String
            
            let startMatchAlert = UIAlertController(title: "Confirm the Start of a New Match", message: "you new match against yourself will start at midnight on \(formatDate(oneDayfromNow))", preferredStyle: UIAlertControllerStyle.alert)
            
            startMatchAlert.addAction(UIAlertAction(title: "Start the match!", style: .default, handler: { (action: UIAlertAction!) in
                
                let newMatch = Match(startDate: self.oneDayfromNow, myID: self.oppID, context: (self.delegate.stack?.context)!)
                newMatch.myAvatar = self.oppAvatar
                newMatch.myName = UserDefaults.standard.object(forKey: "fullName") as? String
                newMatch.finished = false
                newMatch.started = true
                newMatch.raceLocation = raceID
                newMatch.finishDate = nil
                newMatch.winner = nil
                newMatch.rejected = nil
                
                let onlineRace = CKRecord(recordType: "match")
                onlineRace["myID"] = myID as CKRecordValue?
                onlineRace["oppID"] = nil as CKRecordValue?
                onlineRace["d" + myID] = 0.0 as CKRecordValue?
                onlineRace["d" + self.oppID] = nil as CKRecordValue?
                onlineRace["started"] = "true" as CKRecordValue?
                onlineRace["finished"] = "false" as CKRecordValue?
                onlineRace["startDate"] = self.oneDayfromNow as CKRecordValue?
                onlineRace["finishDate"] = "" as CKRecordValue?
                onlineRace["winner"] = "" as CKRecordValue?
                onlineRace["raceLocation"] = raceID as CKRecordValue?
                onlineRace["rejected"] = "false" as CKRecordValue?
                onlineRace["started"] = "true" as CKRecordValue?

                let defaultContainer = CKContainer.default()
                
                let publicDB = defaultContainer.publicCloudDatabase
                
                publicDB.save(onlineRace, completionHandler: { (record, error) -> Void in
                    guard let record = record else {
                        self.displayAlert("Error saving record:  \(error)")
                        return
                    }
                    
                    newMatch.recordID = record.recordID
                    
                    self.delegate.stack?.context.perform{
                        print("saving context")
                        self.delegate.stack?.save()
                        print("context saved")
                    }
                    
                }) 
                
                self.delegate.stack?.context.perform{
                    self.delegate.stack?.save()
                }
                
                let controller: MainPageViewController
                controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                
                self.navigationController?.pushViewController(controller, animated: true)
                
            }))
            
            startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(startMatchAlert, animated: true, completion: nil)
            
        } else {
            
            let myID = UserDefaults.standard.object(forKey: "myID") as! String
            
            let startMatchAlert = UIAlertController(title: "Confirm the Start of a New Match", message: "Your new match against \(self.oppName) will start the day following being accepted at midnight", preferredStyle: UIAlertControllerStyle.alert)
            startMatchAlert.addAction(UIAlertAction(title: "Send Race Request!", style: .default, handler: { (action: UIAlertAction!) in
                
                performUIUpdatesOnMain{
                    self.activityIndicator.startAnimating()
                }
                
                let newMatch = Match(startDate: self.oneDayfromNow, myID: myID, context: (self.delegate.stack!.context))
                newMatch.myName = UserDefaults.standard.object(forKey: "fullName") as? String
                newMatch.myAvatar = UserDefaults.standard.object(forKey: "myAvatar") as? Data
                newMatch.oppID = self.oppID
                newMatch.oppName = self.oppName
                newMatch.oppAvatar = self.oppAvatar
                newMatch.finished = false
                newMatch.started = false
                newMatch.raceLocation = raceID
                newMatch.winner = nil
                newMatch.myFinishDate = nil
                newMatch.oppFinishDate = nil
                newMatch.rejected = nil
    
                let onlineRace = CKRecord(recordType: "match")
                onlineRace["myID"] = myID as CKRecordValue?
                onlineRace["oppID"] = self.oppID as CKRecordValue?
                onlineRace["d" + myID] = 0.0 as CKRecordValue?
                onlineRace["d" + self.oppID] = 0.0 as CKRecordValue?
                onlineRace["u" + self.oppID] = self.oneDayfromNow as CKRecordValue?
                onlineRace["u" + myID] = self.oneDayfromNow as CKRecordValue?
                onlineRace["started"] = "false" as CKRecordValue?
                onlineRace["finished"] = "false" as CKRecordValue?
                onlineRace["startDate"] = self.oneDayfromNow as CKRecordValue?
                onlineRace["myFinishDate"] = "" as CKRecordValue?
                onlineRace["oppFinishDate"] = "" as CKRecordValue?
                onlineRace["winner"] = "" as CKRecordValue?
                onlineRace["raceLocation"] = raceID as CKRecordValue?
                onlineRace["rejected"] = "false" as CKRecordValue?
                
                let defaultContainer = CKContainer.default()
                
                let publicDB = defaultContainer.publicCloudDatabase
                
                publicDB.save(onlineRace, completionHandler: { (record, error) -> Void in
                    guard let record = record else {
                        print("Error saving record: ", error)
                        return
                    }
                    
                    newMatch.recordID = record.recordID
                    
                    let controller: MainPageViewController
                    controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                    
                    self.delegate.stack?.context.perform {
                        self.delegate.stack?.save()
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }) 
            }))
            
            startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(startMatchAlert, animated: true, completion: nil)
        }
    }
}
