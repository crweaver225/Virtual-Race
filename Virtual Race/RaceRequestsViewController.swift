//
//  RaceRequestsViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/9/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


class RaceRequestsViewController: ViewControllerMethods, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func refresh(sender: AnyObject) {
        viewWillAppear(false)
    }
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var requestList = [CKRecord]()
    
    var friendList = [[String:AnyObject]]()
    
    var imageList = [NSData]()
    
    var oppName = String()
    
    var oneDayfromNow: NSDate {
        
        let date = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: [])!
        return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
    }

    override func viewWillAppear(animated:Bool) {
        
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        
        let friends = retrieveFBFriends()
        friends.getFriends() { (friendsList, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Access Token")
                    
                    let controller: MainPageViewController
                    controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainPageViewController") as! MainPageViewController
                    
                    performUIUpdatesOnMain{
                        self.presentViewController(controller, animated: false, completion: nil)
                    }
                    
                } else if error as? Int == 001 {
                    self.displayAlert("No internet connection")
                    self.activityIndicator.stopAnimating()
                    
                } else {
                    self.displayAlert("There was a problem accessing the fitbit servers, please try again later")
                    self.activityIndicator.stopAnimating()
                }
                
                return
            }

            self.friendList = friendsList!
            
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
                        self.displayAlert("Unable to connect to the server. Make sure you are signed into your iCloud account")
                        self.activityIndicator.stopAnimating()
                        return
                    }
                
                    self.requestList = records
                
                    performUIUpdatesOnMain{
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                }
                
            } else {
                self.displayAlert("Unable to connect to the server. Make sure you are signed into your iCloud account")
                self.activityIndicator.stopAnimating()
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return requestList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var oppAvatar = String()
        
        let extraInfo = MapViewController()
        
        let cell = tableView.dequeueReusableCellWithIdentifier("raceRequests")!
        
        let row = requestList[indexPath.row]
        
        let raceLocation = extraInfo.chooseRaceCourse((row.objectForKey("raceLocation") as? String)!)
        
        for i in friendList {
            
            guard let user = i["user"] as? [String:AnyObject] else {
                print("could not get user")
                return cell
            }
            
            guard let encodedID = user["encodedId"] as? String else {
                print("no encoded ID")
                return cell
            }
            
            guard let name = user["displayName"] as? String else {
                print("could not get name")
                return cell
            }
            
            if encodedID == row.objectForKey("myID") as! String {
                
                guard let avatar = user["avatar"] as? String else {
                    print("no opp avatar")
                    return cell
                }
                
                self.oppName = name
                
                oppAvatar = avatar
                
                cell.textLabel?.text = "\(name) has challenged you to a race"
                
                cell.detailTextLabel!.text = "The race would start in \(raceLocation!.startingTitle) and end in \(raceLocation!.endingTitle)"
                cell.detailTextLabel?.numberOfLines = 2
                
                let avatarURL = NSURL(string: oppAvatar)
                
                let avatarImage = NSData(contentsOfURL: (avatarURL)!)
                
                self.imageList.insert(avatarImage!, atIndex: indexPath.row)
                
                cell.imageView?.image = UIImage(data: avatarImage!)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = requestList[indexPath.row]
        
        let myID = NSUserDefaults.standardUserDefaults().objectForKey("myID") as? String!
        
        let defaultContainer = CKContainer.defaultContainer()
        
        let publicDB = defaultContainer.publicCloudDatabase
        
        let startMatchAlert = UIAlertController(title: "Confirm the Start of a New Match", message: "your new match against \(self.oppName) will start at midnight on \(formatDate(oneDayfromNow))", preferredStyle: UIAlertControllerStyle.Alert)
        
        startMatchAlert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: {(action: UIAlertAction!) in
            
            if isICloudContainerAvailable() {
                
                for i in self.friendList {
                    
                    guard let user = i["user"] as? [String:AnyObject] else {
                        print("could not get user")
                        return
                    }
                    
                    guard let encodedID = user["encodedId"] as? String else {
                        print("no encoded ID")
                        return
                    }
                    
                    guard let name = user["displayName"] as? String else {
                        print("could not get name")
                        return
                    }
                    
                    if encodedID == row.objectForKey("myID") as? String {
                        
                        let newMatch = Match(startDate: self.oneDayfromNow, myID: myID! , context: (self.delegate.stack?.context)!)
                        newMatch.myName = NSUserDefaults.standardUserDefaults().objectForKey("fullName") as? String
                        newMatch.myAvatar = NSUserDefaults.standardUserDefaults().objectForKey("myAvatar") as? NSData
                        newMatch.oppID = encodedID
                        newMatch.oppName = name
                        newMatch.oppAvatar = self.imageList[indexPath.row]
                        newMatch.finished = false
                        newMatch.started = true
                        newMatch.recordID = row.recordID
                        newMatch.raceLocation = row.objectForKey("raceLocation") as? String
                        
                        row.setObject("true", forKey: "started")
                        row.setObject(self.oneDayfromNow, forKey: "startDate")
                        
                        publicDB.saveRecord(row) { (record, error) -> Void in
                            guard let record = record else {
                                print("Error saving record: ", error)
                                return
                            }
                        }
                        
                        self.delegate.stack?.save()
                        
                        let controller: LoginViewController
                        controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                }
                
            } else {
                
                self.displayAlert("You are not currently signed into your iCloud account or have not permitted Virtual Race to access your iCloud account. Please be sure both of these things are done")
                self.activityIndicator.stopAnimating()
            }
            
            
        }))
        
        startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        startMatchAlert.addAction(UIAlertAction(title: "Deny", style: .Default, handler: {(action: UIAlertAction!) in
            
            if isICloudContainerAvailable() {
                
                row.setObject("true", forKey: "rejected")
                
                publicDB.saveRecord(row) { (record, error) -> Void in
                    guard let record = record else {
                        print("Error saving record: ", error)
                        return
                    }
                }
                
                performUIUpdatesOnMain{
                    self.requestList.removeAtIndex(indexPath.row)
                    self.tableView.reloadData()
                }
                
            } else {
                
                self.displayAlert("You are not currently signed into your iCloud account or have not permitted Virtual Race to access your iCloud account. Please be sure both of these things are done")
                self.activityIndicator.stopAnimating()
            }
            
        }))
        
        self.presentViewController(startMatchAlert, animated: true, completion: nil)
        
    }
}