//
//  PendingRacesViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 10/6/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class PendingRacesViewController: ViewControllerMethods,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pendingRacesLabel: UILabel!
    
    var requestList = [Match]()
    
    var deleteMatchIndexPath: IndexPath? = nil
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated:Bool) {
        
        requestList.removeAll()
        
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
            
            if match.started == false && match.oppID != nil {
                self.requestList.append(match)
            }
            
            let defaultContainer = CKContainer.default()
            
            let publicDB = defaultContainer.publicCloudDatabase
            publicDB.fetch(withRecordID: match.recordID!) { (record, error) -> Void in
                
                guard error == nil else {
                    return
                }
                
                if record!.object(forKey: "started") as? String == "true" {
                    
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

        self.tableView.reloadData()
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
                
                publicDB.fetch(withRecordID: requestList[(indexPath as NSIndexPath).row].recordID!) { (record, error) -> Void in
                    
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
                    
                    self.delegate.stack?.context.delete(self.requestList[(indexPath as NSIndexPath).row])
                    
                    self.requestList.remove(at: (indexPath as NSIndexPath).row)
                    
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            deleteMatchIndexPath = indexPath
            
            let matchToDelete = requestList[(indexPath as NSIndexPath).row]
            
            confirmDelete(matchToDelete)
        }
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
        
        if requestList.count == 0 {
            pendingRacesLabel.isHidden = false
            pendingRacesLabel.text = "You Currently Have No Pending Races"
        } else {
            pendingRacesLabel.isHidden = true
        }
 
        return requestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let extraInfo = MapViewController()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pendingRaces")!
        
        let row = requestList[(indexPath as NSIndexPath).row]
        
        let raceLocation = extraInfo.chooseRaceCourse(row.raceLocation!)!
        
        var avatarImage = Data()
        
            avatarImage = row.oppAvatar! as Data
        
            cell.textLabel?.text = "Race with \(row.oppName!) from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.textLabel!.numberOfLines = 2
            cell.imageView!.image = UIImage(data: avatarImage)
        
        switch row {
            
        case let row where row.rejected == "true" && row.started == false:
            
                cell.textLabel?.text = "\(row.oppName!) has declined this race"
                cell.detailTextLabel?.text = "The race was from \(raceLocation.startingTitle) to \(raceLocation.endingTitle)"
                cell.detailTextLabel?.numberOfLines = 2
                cell.detailTextLabel?.textColor = UIColor.red
            
        default:
                    
            if cell.detailTextLabel?.text != "Waiting for your race request to be accepted" {
                performUIUpdatesOnMain{
                    cell.detailTextLabel!.text = "Waiting for your race request to be accepted"
                    cell.detailTextLabel?.numberOfLines = 2
                }
            }
        }
        
        return cell
    
    }

}
