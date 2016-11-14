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
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var friendList = [[String:AnyObject]]()
    
    var deleteMatchIndexPath: IndexPath? = nil
    
    var raceList = [Match]()
    
    override func viewWillAppear(_ animated:Bool) {
    
        super.viewWillAppear(animated)
        
        noMathesLabel.isHidden = true
        
        raceList.removeAll()
        friendList.removeAll()
        
        self.tableView.reloadData()
        
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
            
            if match.oppID != nil && match.started == true && UserDefaults.standard.bool(forKey: "refresh") == true && match.myFinishDate == nil {
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                    self.updateRaces(match)
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
                        
                        performUIUpdatesOnMain {
                            self.delegate.stack?.save()
                            self.viewWillAppear(true)
                        }
                    }
                    
                    if record!.object(forKey: "winner") as? String != "" && match.winner == nil {
                        match.finished = true
                        match.winner = "Your opponent has finished the race"
                        
                        performUIUpdatesOnMain{
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
            
            if match.started == true {
                raceList.append(match)
            }
        }
        
        raceList.sort {$0.startDate! < $1.startDate!}
        
        UserDefaults.standard.set(false, forKey: "refresh")
            
        self.tableView.reloadData()
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
                
                let extraInfo = MapViewController()
                
                let raceLocation = extraInfo.chooseRaceCourse(match.raceLocation!)!
                
                if myDistance >= raceLocation.distance {
                    
                    if match.finished == false {
                        match.finished = true
                        match.winner = "You have finished the race"
                        
                        performUIUpdatesOnMain{
                            self.tableView.reloadData()
                        }
                    }
                    match.myDistance = raceLocation.distance as NSNumber?
                    
                    let finishDate = RetrieveDistance()
                    finishDate.getFinishDate(raceLocation.distance, date: formatDate(match.startDate!)) { (result, error) in
                        
                        if let result = result {
                            match.myFinishDate = result
                        }
                        
                        self.postUpdates(match, date: date)
                    }
                } else {
                    self.postUpdates(match, date: date)
                }
            }
        }
    }
    
    func postUpdates(_ match: Match, date: Date) {
        
        if isICloudContainerAvailable() {
            
            let defaultContainer = CKContainer.default()
            
            let publicDB = defaultContainer.publicCloudDatabase
            
            publicDB.fetch(withRecordID: match.recordID!) { (record, error) -> Void in
                guard let record = record else {
                    print("Error fetching record: ", error)
                    return
                }
                
                if match.myFinishDate != nil {
                    record.setObject("\(match.myName) has finished the race" as CKRecordValue?, forKey: "winner")
                    if match.initializer == true {
                        record.setObject(match.myFinishDate as CKRecordValue?, forKey: "myFinishDate")
                    } else {
                        record.setObject(match.myFinishDate as CKRecordValue?, forKey: "oppFinishDate")
                    }
                }
                
                if match.initializer == true {
                    record.setObject(match.myDistance, forKey: "racerDistance1")
                    record.setObject(date as CKRecordValue?, forKey: "racerUpdate1")
                } else {
                    record.setObject(match.myDistance, forKey: "racerDistance2")
                    record.setObject(date as CKRecordValue?, forKey: "racerUpdate2")
                }
                
                publicDB.save(record, completionHandler: { (record, error) -> Void in
                    guard let record = record else {
                        print("Error saving record: ", error)
                        return
                    }
                })
            }
        } else {
            print("no icloud account")
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
                    
                        self.tableView.reloadData()
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
            cell.textLabel!.numberOfLines = 3
            cell.imageView!.image = UIImage(data: avatarImage)
            
        }
        
        switch row {
            
        case let row where row.finished == true && row.oppID == nil:
            cell.detailTextLabel?.text = "The race is over!"
            cell.detailTextLabel?.textColor = UIColor.red
            
        case let row where row.rejected == "true" && row.finished == false:
            if row.oppID != nil {
                cell.textLabel?.text = "\(row.oppName!) is no longer participating in the race"
                cell.textLabel?.numberOfLines = 3
                cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
                cell.detailTextLabel?.numberOfLines = 3
            } else {
                cell.textLabel?.text = "This race has been ended"
                cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
                cell.detailTextLabel?.numberOfLines = 3
            }

        case let row where row.finished == true && row.oppID != nil:
            if row.winner! == "tie" {
                cell.detailTextLabel?.text = "The race is over! it was a tie"
                cell.detailTextLabel?.textColor = UIColor.red
                
            } else {
                
                if row.winner == row.myName! || row.winner == row.oppName! {
                    cell.detailTextLabel?.text = "The race is over! \(row.winner!) finished 1st"
                    cell.detailTextLabel?.textColor = UIColor.red
                    cell.detailTextLabel!.numberOfLines = 3
                } else {
                    cell.detailTextLabel?.text = "\(row.winner!)"
                    cell.detailTextLabel?.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)
                    
                    cell.detailTextLabel!.numberOfLines = 3
                }
            }
            
        case let row where row.started == true:
             cell.detailTextLabel!.text = "Race start date: \(formatDate(row.startDate!))"
             cell.detailTextLabel?.textColor = UIColor(red: 0.0, green: 0.502, blue: 0.004, alpha: 1.0)
    
        default:
            print("default")
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
