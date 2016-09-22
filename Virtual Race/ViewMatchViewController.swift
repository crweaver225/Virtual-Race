//
//  ViewMatchViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/7/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit




class ViewMatchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var friendList = [[String:AnyObject]]()
    
    var fetchedResultsController: NSFetchedResultsController!
    
    var deleteMatchIndexPath: NSIndexPath? = nil
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var raceList = [Match]()
    
    var requestChecker = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func returnButton(sender: AnyObject) {
        let controller: LoginWebViewController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginWebViewController") as! LoginWebViewController
        
        self.presentViewController(controller, animated: false, completion: nil)

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return raceList.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let extraInfo = MapViewController()
        
        let cell = tableView.dequeueReusableCellWithIdentifier("currentRaces")!
        
        let row = raceList[indexPath.row]
        
        let raceLocation = extraInfo.chooseRaceCourse(row.raceLocation!)!
        
        var avatarImage = NSData()
        
        if row.oppAvatar == nil {
            avatarImage = row.myAvatar!
            cell.textLabel!.text = "\(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
        } else {
            avatarImage = row.oppAvatar!
            cell.textLabel?.text = "Racing \(row.oppName!) from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            cell.textLabel!.numberOfLines = 2
        }
        
        cell.imageView!.image = UIImage(data: avatarImage)
        
        if row.finished == true && row.oppID == nil {
            
            cell.detailTextLabel?.text = "The race is over!"
            
        } else if row.rejected == "true" {
            
            cell.textLabel?.text = "\(row.oppName!) has declined this race"
            cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            
        } else if row.rejected == "true" && row.started == true && row.finished == false {
            
            cell.textLabel?.text = "\(row.oppName!) is no longer participating in the race"
            cell.textLabel?.numberOfLines = 2
            cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            
        } else if row.finished == true && row.oppID != nil {
            
            if row.winner! == "tie" {
                cell.detailTextLabel?.text = "The race is over! it was a tie"
                
        } else {
            
                if row.winner == row.myName! || row.winner == row.oppName! {
                    cell.detailTextLabel?.text = "The race is over! \(row.winner!) finished 1st"
                    cell.detailTextLabel?.textColor = UIColor(red: 0.0, green: 0.502, blue: 0.004, alpha: 1.0)
                } else {
                    cell.detailTextLabel?.text = "\(row.winner!)"
                    cell.detailTextLabel?.textColor = UIColor.redColor()
                    cell.detailTextLabel!.numberOfLines = 2
                }
            }
        
        } else if row.started == true  {
            
            cell.detailTextLabel!.text = "Race start date: \(formatDate(row.startDate!))"
            
        } else {
            
            let defaultContainer = CKContainer.defaultContainer()
            
            let publicDB = defaultContainer.publicCloudDatabase
            publicDB.fetchRecordWithID(row.recordID!) { (record, error) -> Void in
                
                guard let record = record else {
                    print("Error fetching record: ", error)
                    return
                }
                
                if record.objectForKey("started") as? String == "false" && self.requestChecker == false {
                    performUIUpdatesOnMain{
                        cell.detailTextLabel!.text = "Waiting for your race request to be accepted"
                        self.requestChecker = true
                        self.tableView.reloadData()
                    }
                    
                } else {
                    row.started = true
                    row.startDate = record.objectForKey("startDate") as? NSDate
                    
                    performUIUpdatesOnMain{
                        cell.detailTextLabel!.text = "Race started on \(formatDate(row.startDate!))"
                        self.delegate.stack?.save()
                        self.tableView.reloadData()
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = raceList[indexPath.row]
        
        if row.started! == true  {
        
            let controller: MapViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        
            controller.match = row
        
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            deleteMatchIndexPath = indexPath
            
            let matchToDelete = raceList[indexPath.row]
            
            confirmDelete(matchToDelete)
        }
    }
    
    func confirmDelete(match: Match) {
        
        let alert = UIAlertController(title: "Delete Race Request", message: "Are you sure you want to permanently end and delete this race? If this is a two player race, niether you or your opponent will be able to see race details upon its deletion.", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteMatch)
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteMatch)
        
        alert.addAction(DeleteAction)
        
        alert.addAction(CancelAction)
    
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteMatch(alertAction: UIAlertAction!) -> Void {
        
        if let indexPath = deleteMatchIndexPath {
            
            let defaultContainer = CKContainer.defaultContainer()
            
            let publicDB = defaultContainer.publicCloudDatabase
            
            if isICloudContainerAvailable() {
            
            publicDB.fetchRecordWithID(raceList[indexPath.row].recordID!) { (record, error) -> Void in
                
                guard let record = record else {
                    
                    self.displayAlert((error?.localizedDescription)!)
                    
                    performUIUpdatesOnMain{
                        self.tableView.reloadData()
                    }
                    return
                }
                
                record.setObject("true", forKey: "rejected")
                
                    publicDB.saveRecord(record) { (record, error) -> Void in
                        guard let record = record else {
                            self.displayAlert((error?.localizedDescription)!)
                            performUIUpdatesOnMain{
                                self.tableView.reloadData()
                            }
                            return
                        }
                    }
                
                    self.delegate.stack?.context.deleteObject(self.raceList[indexPath.row])
                    
                    self.raceList.removeAtIndex(indexPath.row)
                    
                    self.delegate.stack?.save()
                    
                    self.deleteMatchIndexPath = nil
                    
                    performUIUpdatesOnMain{
                        self.tableView.beginUpdates()
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        self.tableView.endUpdates()
                    }
                }
            } else {
                performUIUpdatesOnMain{
                    self.displayAlert("You cannot delete this race without being signed into an iCloud account")
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func cancelDeleteMatch(alertAction: UIAlertAction!) {
        deleteMatchIndexPath = nil
    }
    
    override func viewWillAppear(animated:Bool) {
        
        super.viewWillAppear(animated)
        
        self.raceList.removeAll()
        
        let fr = NSFetchRequest(entityName: "Match")
        fr.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        fr.sortDescriptors = [NSSortDescriptor(key: "finished", ascending: true)]
        
        let predicate = NSPredicate(format: "myID = %@", argumentArray: [NSUserDefaults.standardUserDefaults().objectForKey("myID")!])
        
        fr.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (delegate.stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        for objects in fetchedResultsController.fetchedObjects! {
            
            let match = objects as? Match
            
            if match?.oppID != nil && match?.started == true &&  NSUserDefaults.standardUserDefaults().boolForKey("refresh") == true {
                
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                    self.updateRaces(match!)
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "refresh")
                }
            }
            
            if match!.oppID != nil {
                
                let defaultContainer = CKContainer.defaultContainer()
                
                let publicDB = defaultContainer.publicCloudDatabase
                publicDB.fetchRecordWithID(match!.recordID!) { (record, error) -> Void in
                    
                    guard error == nil else {
                        return
                    }
                    
                    if record!.objectForKey("started") as? String == "true" && match?.started == false {
                        match!.started = true
                        match?.startDate = record?.objectForKey("startDate") as? NSDate
                        performUIUpdatesOnMain{
                            self.delegate.stack?.save()
                            self.tableView.reloadData()
                        }
                    }
                    
                    if record!.objectForKey("rejected") as! String == "true" {
                        match?.rejected = "true"
                        performUIUpdatesOnMain{
                            self.delegate.stack?.save()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
            raceList.append(match!)
        }
 
        self.tableView.reloadData()
        
        self.searchAllRaces()
    }
    
    func updateRaces(match: Match) {
        
        let date = NSDate()
            
            let newDistance = RetrieveDistance()
            newDistance.getDistance(formatDate(match.startDate!)){ (result, error) in
                
                guard (error == nil) else {
                    
                    if error as? Int == 401 {
                        
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Access Token")
                        
                        let controller: LoginWebViewController
                        controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginWebViewController") as! LoginWebViewController
                        
                        performUIUpdatesOnMain{
                            self.presentViewController(controller, animated: false, completion: nil)
                        }
                    }
                    
                    return
                }
            
                match.myDistance = result
               
                let defaultContainer = CKContainer.defaultContainer()
                
                let publicDB = defaultContainer.publicCloudDatabase
                
                publicDB.fetchRecordWithID(match.recordID!) { (record, error) -> Void in
                    guard let record = record else {
                        print("Error fetching record: ", error)
                        return
                    }
                
                record.setObject(date, forKey: "u" + match.myID!)
                    
                    if isICloudContainerAvailable() {
                        
                        record.setObject(match.myDistance, forKey: "d" + match.myID!)
                        
                        publicDB.saveRecord(record) { (record, error) -> Void in
                            guard let record = record else {
                                print("Error saving record: ", error)
                                return
                            }
                        }
                    } else {
                        print("no icloud account")
                    }
                }
            }
        }
    
    func searchAllRaces() {
        
        let defaultContainer = CKContainer.defaultContainer()
        
        let publicDB = defaultContainer.publicCloudDatabase
        
        let predicate = NSPredicate(format: "%K == %@", "myID", (NSUserDefaults.standardUserDefaults().objectForKey("myID") as? String!)!)
        
        let predicate2 = NSPredicate(format: "%K == %@", "oppID", (NSUserDefaults.standardUserDefaults().objectForKey("myID") as? String!)!)
        
        var query = CKQuery(recordType: "match", predicate: predicate)
        
        publicDB.performQuery(query, inZoneWithID: nil) {
            (records, error) -> Void in
            guard let records = records else {
                print("Error querying records: ", error)
                return
            }
                for record in records {
                    
                if record.objectForKey("started") as! String == "true" {
                
                self.checkRacesAgainstMemory(records)
                    
                }
            }
        }
        
        query = CKQuery(recordType: "match", predicate: predicate2)
        
        publicDB.performQuery(query, inZoneWithID: nil) { (records, error) -> Void in
            
            guard let records = records else {
                print("Error querying records: ", error)
                return
            }
            
            for record in records {
                    
                if record.objectForKey("started") as! String == "true" {
                        
                    self.checkRacesAgainstMemory(records)
                }
            }
        }
    }
    
    func checkRacesAgainstMemory(record: [CKRecord]) {
        
        let fr = NSFetchRequest(entityName: "Match")
        fr.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]

        for object in record {
                
            if object.objectForKey("rejected") as! String != "true" {
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (delegate.stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
                
                do {
                    try fetchedResultsController.performFetch()
                } catch {
                    print("could not perform fetch")
                }
                    
                var counter = 0
                    
                for objects in fetchedResultsController.fetchedObjects! {
                    
                    let match = objects as! Match
                    
                    if match.recordID?.recordName == object.recordID.recordName {
                        counter += 1
                    }
                }
                if counter == 0 {
                    addRacetoMemory(object)
                }
            }
        }
    }
    
    func addRacetoMemory(record: CKRecord) {

        let newMatch = Match(startDate: (record.objectForKey("startDate") as! NSDate), myID: NSUserDefaults.standardUserDefaults().objectForKey("myID") as! String, context: (self.delegate.stack?.context)!)
        newMatch.recordID = record.recordID
        newMatch.myName = NSUserDefaults.standardUserDefaults().objectForKey("fullName") as? String
        newMatch.myAvatar = NSUserDefaults.standardUserDefaults().objectForKey("myAvatar") as? NSData
        newMatch.raceLocation = record.objectForKey("raceLocation") as? String
        newMatch.winner = record.objectForKey("winner") as? String
        newMatch.finishDate = record.objectForKey("finishDate") as? String
        
        let started = record.objectForKey("started") as? String
        
        if started! == "true" {
            
            newMatch.started = true
            
        } else {
            
            newMatch.started = false
            
        }
        
        let finished = record.objectForKey("finished") as? String
        
        if finished! == "true" {
            
            newMatch.finished = true
            
        } else {
            
            newMatch.finished = false
            
        }
        
        if record.objectForKey("myID") as! String == NSUserDefaults.standardUserDefaults().objectForKey("myID") as! String && record.objectForKey("oppID") != nil {
            
            let oppID = record.objectForKey("oppID") as! String
            
            newMatch.oppID = oppID
            newMatch.oppDistance = record.objectForKey("d" + newMatch.oppID!) as! Double
            
        } else if record.objectForKey("oppID") as? String == NSUserDefaults.standardUserDefaults().objectForKey("myID") as? String {
            
            let oppID = record.objectForKey("myID") as! String
            
            newMatch.oppID = oppID
        }
        
        let friends = retrieveFBFriends()
        
        friends.getFriends() { (friendsList, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            self.friendList = friendsList!
            
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
                
                if encodedID == newMatch.oppID {
                
                    guard let avatar = user["avatar"] as? String else {
                        print("no opp avatar")
                        return
                    }
                    
                    let avatarURL = NSURL(string: avatar)
                    
                    let avatarImage = NSData(contentsOfURL: (avatarURL)!)
                    
                    newMatch.oppAvatar = avatarImage
                    newMatch.oppName = name
                    
                }
                
            }
            
            self.delegate.stack?.context.performBlock{
                self.delegate.stack?.save()
                self.raceList.append(newMatch)
                self.tableView.reloadData()
            }
        }
    }
    
    func displayAlert(text: String) {
        
        let networkAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.Alert)
        networkAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        self.presentViewController(networkAlert, animated: true, completion: nil)
    }
 
}