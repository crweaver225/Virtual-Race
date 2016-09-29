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
    
    @IBOutlet weak var noRequestsLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func refresh(_ sender: AnyObject) {
        viewWillAppear(false)
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var requestList = [CKRecord]()
    
    var friendList = [[String:AnyObject]]()
    
    var imageList = [Data]()
    
    var oppName = String()
    
    var oneDayfromNow: Date {
        
        let date = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: Date(), options: [])!
        return (Calendar.current as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: date, options: NSCalendar.Options())!
    }

    override func viewWillAppear(_ animated:Bool) {
        
        super.viewWillAppear(animated)
        
        noRequestsLabel.isHidden = true
        
        activityIndicator.startAnimating()
        
        let friends = retrieveFBFriends()
        friends.getFriends() { (friendsList, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    UserDefaults.standard.set(nil, forKey: "Access Token")
                    
                    let controller: MainPageViewController
                    controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                    
                    performUIUpdatesOnMain{
                        self.present(controller, animated: false, completion: nil)
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
                        self.displayAlert("Unable to connect to the server. Make sure you are signed into your iCloud account")
                        self.activityIndicator.stopAnimating()
                        return
                    }
                
                    self.requestList = records
                    
                    if self.requestList.count == 0 {
                        performUIUpdatesOnMain {

                        self.noRequestsLabel.isHidden = false
                        self.noRequestsLabel.text = "You Have No New Race Requests."
                        }
                    }
                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return requestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var oppAvatar = String()
        
        let extraInfo = MapViewController()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "raceRequests")!
        
        let row = requestList[(indexPath as NSIndexPath).row]
        
        let raceLocation = extraInfo.chooseRaceCourse((row.object(forKey: "raceLocation") as? String)!)
        
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
            
            if encodedID == row.object(forKey: "myID") as! String {
                
                guard let avatar = user["avatar"] as? String else {
                    print("no opp avatar")
                    return cell
                }
                
                self.oppName = name
                
                oppAvatar = avatar
                
                cell.textLabel?.text = "\(name) has challenged you to a race"
                
                cell.detailTextLabel!.text = "The race would start in \(raceLocation!.startingTitle) and end in \(raceLocation!.endingTitle)"
                cell.detailTextLabel?.numberOfLines = 2
                
                let avatarURL = URL(string: oppAvatar)
                
                let avatarImage = try? Data(contentsOf: (avatarURL)!)
                
                self.imageList.insert(avatarImage!, at: (indexPath as NSIndexPath).row)
                
                cell.imageView?.image = UIImage(data: avatarImage!)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = requestList[(indexPath as NSIndexPath).row]
        
        let myID = UserDefaults.standard.object(forKey: "myID") as? String!
        
        let defaultContainer = CKContainer.default()
        
        let publicDB = defaultContainer.publicCloudDatabase
        
        let startMatchAlert = UIAlertController(title: "Confirm the Start of a New Match", message: "your new match against \(self.oppName) will start at midnight on \(formatDate(oneDayfromNow))", preferredStyle: UIAlertControllerStyle.alert)
        
        startMatchAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {(action: UIAlertAction!) in
            
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
                    
                    if encodedID == row.object(forKey: "myID") as? String {
                        
                        let newMatch = Match(startDate: self.oneDayfromNow, myID: myID! , context: (self.delegate.stack?.context)!)
                        
                        
                        newMatch.myName = UserDefaults.standard.object(forKey: "fullName") as? String
                        newMatch.myAvatar = UserDefaults.standard.object(forKey: "myAvatar") as? Data
                        newMatch.oppID = encodedID
                        newMatch.oppName = name
                        newMatch.oppAvatar = self.imageList[(indexPath as NSIndexPath).row]
                        newMatch.finished = false
                        newMatch.started = true
                        newMatch.recordID = row.recordID
                        newMatch.raceLocation = row.object(forKey: "raceLocation") as? String
                        newMatch.oppDistance = 0.0
                        newMatch.myDistance = 0.0
                        
                        row.setObject("true" as CKRecordValue?, forKey: "started")
                        row.setObject(self.oneDayfromNow as CKRecordValue?, forKey: "startDate")
                        
                        publicDB.save(row, completionHandler: { (record, error) -> Void in
                            guard let record = record else {
                                print("Error saving record: ", error)
                                return
                            }
                        }) 
                        
                        self.delegate.stack?.save()
                        
                        let controller: MainPageViewController
                        controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                }
                
            } else {
                
                self.displayAlert("You are not currently signed into your iCloud account or have not permitted Virtual Race to access your iCloud account. Please be sure both of these things are done")
                self.activityIndicator.stopAnimating()
            }
            
            
        }))
        
        startMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        startMatchAlert.addAction(UIAlertAction(title: "Deny", style: .default, handler: {(action: UIAlertAction!) in
            
            if isICloudContainerAvailable() {
                
                row.setObject("true" as CKRecordValue?, forKey: "rejected")
                
                publicDB.save(row, completionHandler: { (record, error) -> Void in
                    guard let record = record else {
                        print("Error saving record: ", error)
                        return
                    }
                }) 
                
                performUIUpdatesOnMain{
                    self.requestList.remove(at: (indexPath as NSIndexPath).row)
                    self.tableView.reloadData()
                }
                
            } else {
                
                self.displayAlert("You are not currently signed into your iCloud account or have not permitted Virtual Race to access your iCloud account. Please be sure both of these things are done")
                self.activityIndicator.stopAnimating()
            }
            
        }))
        
        self.present(startMatchAlert, animated: true, completion: nil)
        
    }
}
