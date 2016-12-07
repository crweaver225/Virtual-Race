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

class ChooseRouteViewController: ViewControllerMethods, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let courses = ["2","4","1","3"]
    
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
                newMatch.rejected = "false"
                newMatch.oppID = nil
                newMatch.initializer = true
                
                let onlineRace = CKRecord(recordType: "match")
                onlineRace["myID"] = myID as CKRecordValue?
                onlineRace["oppID"] = "" as CKRecordValue?
                onlineRace["racerDistance1"] = 0.0 as CKRecordValue?
                onlineRace["racerUpdate1"] = nil as CKRecordValue?
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
                        
                        self.delegate.stack?.save()
                        
                        let controller: MainPageViewController
                        controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                    
                })
                
            }))
            
            startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(startMatchAlert, animated: true, completion: nil)
            
        } else {
            
            let myID = UserDefaults.standard.object(forKey: "myID") as! String
            
            let startMatchAlert = UIAlertController(title: "Confirm the Start of a New Match", message: "Your new match against \(self.oppName) will start at midnight following being accepted", preferredStyle: UIAlertControllerStyle.alert)
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
                newMatch.rejected = "false"
                newMatch.initializer = true
               
                
                let onlineRace = CKRecord(recordType: "match")
                onlineRace["myID"] = myID as CKRecordValue?
                onlineRace["oppID"] = self.oppID as CKRecordValue?
                onlineRace["racerDistance1"] = 0.0 as CKRecordValue?
                onlineRace["racerDistance2"] = 0.0 as CKRecordValue?
                onlineRace["racerUpdate1"] = self.oneDayfromNow as CKRecordValue?
                onlineRace["racerUpdate2"] = self.oneDayfromNow as CKRecordValue?
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
                    
                    self.delegate.stack?.context.perform {
                        let controller: MainPageViewController
                        controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                        self.delegate.stack?.save()
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                })
                
                
            }))
            
            startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(startMatchAlert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseType", for: indexPath) as! RaceTableViewCell
        
        let row = courses[indexPath.row]
        
        switch row {
        case "2":
            cell.raceImage.image = UIImage(named: "Cross_Town_Class")
        case "1":
            cell.raceImage.image = UIImage(named: "NY-LA")
        case "3":
            cell.raceImage.image = UIImage(named: "Liberty-Run")
        case "4":
            cell.raceImage.image = UIImage(named: "mardiGrasShuffle")
        default:
            print("default")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = courses[indexPath.row]
        
        chooseRace(row)
        
    }
}

