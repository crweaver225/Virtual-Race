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

class ViewMatchViewController: ViewControllerMethods, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noMathesLabel: UILabel!
    
    var friendList = [[String:AnyObject]]()
    
    var deleteMatchIndexPath: IndexPath? = nil
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var raceList = [Match]()
    
    var requestChecker = false
    
    
    override func viewWillAppear(_ animated:Bool) {
    
        super.viewWillAppear(animated)
        
        noMathesLabel.isHidden = true
        
        raceList.removeAll()
        
        let fr = NSFetchRequest<Match>(entityName: "Match")
        fr.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        fr.sortDescriptors = [NSSortDescriptor(key: "finished", ascending: true)]
        
        let predicate = NSPredicate(format: "myID = %@", argumentArray: [UserDefaults.standard.object(forKey: "myID")!])
        
        fr.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (delegate.stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        for objects in fetchedResultsController.fetchedObjects! {
            
            let match = objects
            
            if match.oppID != nil && match.started == true && UserDefaults.standard.bool(forKey: "refresh") == true {
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                    self.updateRaces(match)
                    UserDefaults.standard.set(false, forKey: "refresh")
                }
            }
            
            if match.oppID == nil {
                
                let defaultContainer = CKContainer.default()
                
                let publicDB = defaultContainer.publicCloudDatabase
                publicDB.fetch(withRecordID: match.recordID!) { (record, error) -> Void in
                    
                    guard error == nil else {
                        return
                    }
                    
                    if record!.object(forKey: "rejected") as! String == "true" {
                        match.rejected = "true"
                        performUIUpdatesOnMain{
                            self.delegate.stack?.save()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
            if match.oppID != nil {
                
                let defaultContainer = CKContainer.default()
                
                let publicDB = defaultContainer.publicCloudDatabase
                publicDB.fetch(withRecordID: match.recordID!) { (record, error) -> Void in
                    
                    guard error == nil else {
                        return
                    }
                    
                    if record!.object(forKey: "started") as? String == "true" && match.started == false {

                        match.started = true
                        match.startDate = record?.object(forKey: "startDate") as? Date
                        
                        performUIUpdatesOnMain{
                            self.delegate.stack?.save()
                            self.tableView.reloadData()
                        }
                    }
                    
                    if record!.object(forKey: "rejected") as! String == "true" {
                        match.rejected = "true"
                        performUIUpdatesOnMain{
                            self.delegate.stack?.save()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
            raceList.append(match)
            
        }
        
        searchAllRaces()
        
        tableView.reloadData()
    }
    
    func updateRaces(_ match: Match) {
        
        let date = Date()
        
        if match.startDate!.compare(date) == ComparisonResult.orderedAscending {
            
            let newDistance = RetrieveDistance()
            newDistance.getDistance(formatDate(match.startDate!)){ (result, error) in
                
                guard (error == nil) else {
                    
                    if error as? Int == 401 {
                        
                        UserDefaults.standard.removeObject(forKey: "Access Token")
                        
                        let controller: MainPageViewController
                        controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                        
                        performUIUpdatesOnMain{
                            self.present(controller, animated: false, completion: nil)
                        }
                    }
                    
                    return
                }
            
                let myDistance = result! as Double * 1609.344
                
                match.myDistance = myDistance as NSNumber?
                
                let defaultContainer = CKContainer.default()
                
                let publicDB = defaultContainer.publicCloudDatabase
                
                publicDB.fetch(withRecordID: match.recordID!) { (record, error) -> Void in
                    guard let record = record else {
                        print("Error fetching record: ", error)
                        return
                    }
                
                record.setObject(date as CKRecordValue?, forKey: "u" + match.myID!)
                    
                    if isICloudContainerAvailable() {
                        
                        record.setObject(match.myDistance, forKey: "d" + match.myID!)
                        
                        publicDB.save(record, completionHandler: { (record, error) -> Void in
                            guard let record = record else {
                                print("Error saving record: ", error)
                                return
                            }
                        })
                        
                    } else {
                        print("no icloud account")
                    }
                }
            }
        }
    }
    
    func searchAllRaces() {
    
        let defaultContainer = CKContainer.default()
        
        let publicDB = defaultContainer.publicCloudDatabase
        
        let predicate = NSPredicate(format: "%K == %@", "myID", (UserDefaults.standard.object(forKey: "myID") as? String!)!)
        
        let predicate2 = NSPredicate(format: "%K == %@", "oppID", (UserDefaults.standard.object(forKey: "myID") as? String!)!)
        
        var query = CKQuery(recordType: "match", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) {
            
            (records, error) -> Void in
            guard let records = records else {
                print("Error querying records: ", error)
                return
            }
                for record in records {
                    
                    if record.object(forKey: "started") as! String == "true"  {
                
                self.checkRacesAgainstMemory(records)
                    
                }
            }
        }
        
        query = CKQuery(recordType: "match", predicate: predicate2)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) -> Void in
            
            guard let records = records else {
                print("Error querying records: ", error)
                return
            }
            
            for record in records {
                    
                if record.object(forKey: "started") as! String == "true"  {
                        
                    self.checkRacesAgainstMemory(records)
                }
            }
        }
    }
    
    func checkRacesAgainstMemory(_ record: [CKRecord]) {
        
    //    print("tytlol \(record)")
        
        let fr = NSFetchRequest<Match>(entityName: "Match")
        fr.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]

        for recordObject in record {
                
            if recordObject.object(forKey: "rejected") as! String != "true" {
                
                let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (delegate.stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
                
                do {
                    try fetchedResultsController.performFetch()
                } catch {
                    print("could not perform fetch")
                }
                    
                var counter = 0
                    
                for match in fetchedResultsController.fetchedObjects! {
                    
                    if match.recordID?.recordName == recordObject.recordID.recordName {
                        
                        counter += 1
                    }
                }
                
                if counter == 0 {
                    addRacetoMemory(recordObject)
                }
            }
        }
    }
    
    func addRacetoMemory(_ record: CKRecord) {
        
        let newMatch = Match(startDate: (record.object(forKey: "startDate") as! Date), myID: UserDefaults.standard.object(forKey: "myID") as! String, context: (self.delegate.stack?.context)!)
        newMatch.recordID = record.recordID
        newMatch.myName = UserDefaults.standard.object(forKey: "fullName") as? String
        newMatch.myAvatar = UserDefaults.standard.object(forKey: "myAvatar") as? Data
        newMatch.raceLocation = record.object(forKey: "raceLocation") as? String
        newMatch.winner = record.object(forKey: "winner") as? String
        newMatch.finishDate = record.object(forKey: "finishDate") as? String
        
        let started = record.object(forKey: "started") as? String
        
        if started! == "true" {
            
            newMatch.started = true
            
        } else {
            
            newMatch.started = false
            
        }
        
        let finished = record.object(forKey: "finished") as? String
        
        if finished! == "true" {
            
            newMatch.finished = true
            
        } else {
            
            newMatch.finished = false
            
        }
        
        if record.object(forKey: "myID") as! String == UserDefaults.standard.object(forKey: "myID") as! String && record.object(forKey: "oppID") != nil {
            
            let oppID = record.object(forKey: "oppID") as! String
            
            newMatch.oppID = oppID
            newMatch.oppDistance = record.object(forKey: "d" + newMatch.oppID!) as! NSNumber?
            
        } else if record.object(forKey: "oppID") as? String == UserDefaults.standard.object(forKey: "myID") as? String {
            
            let oppID = record.object(forKey: "myID") as! String
            
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
                    
                    let avatarURL = URL(string: avatar)
                    
                    let avatarImage = try? Data(contentsOf: (avatarURL)!)
                    
                    newMatch.oppAvatar = avatarImage
                    newMatch.oppName = name
                    
                }
                
            }
            
            self.delegate.stack?.context.perform{
                self.delegate.stack?.save()
                self.raceList.append(newMatch)
                self.tableView.reloadData()
            }
            
        }
    }
    
    func confirmDelete(_ match: Match) {
        
        let alert = UIAlertController(title: "Delete Race Request", message: "Are you sure you want to permanently end and delete this race? If this is a two player race, niether you or your opponent will be able to see race details upon its deletion.", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteMatch)
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteMatch)
        
        alert.addAction(DeleteAction)
        
        alert.addAction(CancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeleteMatch(_ alertAction: UIAlertAction!) -> Void {
        
        if let indexPath = deleteMatchIndexPath {
            
            let defaultContainer = CKContainer.default()
            
            let publicDB = defaultContainer.publicCloudDatabase
            
            if isICloudContainerAvailable()  {
                
                publicDB.fetch(withRecordID: raceList[(indexPath as NSIndexPath).row].recordID!) { (record, error) -> Void in
                    
                    guard (error == nil) else {
                        self.displayAlert((error?.localizedDescription)! + " You will not be able to delete this race until the issue is fixed.")
                        performUIUpdatesOnMain{
                            self.tableView.reloadData()
                        }
                        return
                    }
                    
                    guard let record = record else {
                        
                        self.displayAlert((error?.localizedDescription)!)
                        
                        performUIUpdatesOnMain{
                            self.tableView.reloadData()
                        }
                        return
                    }
                    
                    record.setObject("true" as CKRecordValue?, forKey: "rejected")
                    
                    publicDB.save(record, completionHandler: { (record, error) -> Void in
                        guard let record = record else {
                            self.displayAlert((error?.localizedDescription)!)
                            performUIUpdatesOnMain{
                                self.tableView.reloadData()
                            }
                            return
                        }
                    }) 
                    
                    self.delegate.stack?.context.delete(self.raceList[(indexPath as NSIndexPath).row])
                    
                    self.raceList.remove(at: (indexPath as NSIndexPath).row)
                    
                    self.delegate.stack?.save()
                    
                    self.deleteMatchIndexPath = nil
                    
                    performUIUpdatesOnMain{
                    
                        self.viewWillAppear(false)
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
    
    func cancelDeleteMatch(_ alertAction: UIAlertAction!) {
        deleteMatchIndexPath = nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.contentView.backgroundColor != UIColor.clear {
        
        cell.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 120))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
            
        }
    }
 
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if raceList.count == 0 {
            noMathesLabel.isHidden = false
            noMathesLabel.text = "You Currently Have No Races"
        } else {
            noMathesLabel.isHidden = true
        }
        
        return raceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let extraInfo = MapViewController()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentRaces")!
        
        let row = raceList[(indexPath as NSIndexPath).row]
        
        let raceLocation = extraInfo.chooseRaceCourse(row.raceLocation!)!
        
        var avatarImage = Data()
        
        if row.oppAvatar == nil{
            avatarImage = row.myAvatar! as Data
            cell.textLabel!.text = "\(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.imageView!.image = UIImage(data: avatarImage)
            
        } else {
            avatarImage = row.oppAvatar! as Data
            cell.textLabel?.text = "Racing \(row.oppName!) from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.textLabel!.numberOfLines = 2
            cell.imageView!.image = UIImage(data: avatarImage)
            
        }
        
        switch row {
            
        case let row where row.finished == true && row.oppID == nil:
            cell.detailTextLabel?.text = "The race is over!"
            cell.detailTextLabel?.textColor = UIColor.red
            
        case let row where row.rejected == "true":
            if row.oppID != nil {
            cell.textLabel?.text = "\(row.oppName!) has declined this race"
            cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            } else {
                cell.textLabel?.text = "This race has been ended"
                cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            }
            
        case let row where row.rejected == "true" && row.started == true && row.finished == false:
            cell.textLabel?.text = "\(row.oppName!) is no longer participating in the race"
            cell.textLabel?.numberOfLines = 2
            cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            
        case let row where row.finished == true && row.oppID != nil:
            if row.winner! == "tie" {
                cell.detailTextLabel?.text = "The race is over! it was a tie"
                cell.detailTextLabel?.textColor = UIColor.red
                
            } else {
                
                if row.winner == row.myName! || row.winner == row.oppName! {
                    cell.detailTextLabel?.text = "The race is over! \(row.winner!) finished 1st"
                    cell.detailTextLabel?.textColor = UIColor.red
                } else {
                    cell.detailTextLabel?.text = "\(row.winner!)"
                    cell.detailTextLabel?.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)
                    
                    cell.detailTextLabel!.numberOfLines = 2
                }
            }
            
        case let row where row.started == true:
             cell.detailTextLabel!.text = "Race start date: \(formatDate(row.startDate!))"
             cell.detailTextLabel?.textColor = UIColor(red: 0.0, green: 0.502, blue: 0.004, alpha: 1.0)
    
        default:
            
            let defaultContainer = CKContainer.default()
            
            let publicDB = defaultContainer.publicCloudDatabase
            publicDB.fetch(withRecordID: row.recordID!) { (record, error) -> Void in
                
                guard let record = record else {
                    print("Error fetching record: ", error)
                    return
                }
                
                if record.object(forKey: "started") as? String == "false" && self.requestChecker == false {
                    
                    
                    performUIUpdatesOnMain{
                        cell.detailTextLabel!.text = "Waiting for your race request to be accepted"
                        self.requestChecker = true
                        self.tableView.reloadData()
                    }
                    
                } else if record.object(forKey: "started") as? String == "true" {
                    row.started = true
                    row.startDate = record.object(forKey: "startDate") as? Date
                    self.requestChecker = false
                    
                    performUIUpdatesOnMain{
                        cell.detailTextLabel!.text = "Race started on \(formatDate(row.startDate!))"
                        cell.detailTextLabel?.textColor = UIColor(red: 0.0, green: 0.502, blue: 0.004, alpha: 1.0)
                        self.delegate.stack?.save()
                        self.tableView.reloadData()
                    }
                }
            }
        }
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = raceList[(indexPath as NSIndexPath).row]
        
        if row.started! == true && row.rejected != "true"  {
            
            let controller: MapViewController
            controller = self.storyboard!.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            
            controller.match = row
            
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            deleteMatchIndexPath = indexPath
            
            let matchToDelete = raceList[(indexPath as NSIndexPath).row]
            
            confirmDelete(matchToDelete)
        }
    }
}
