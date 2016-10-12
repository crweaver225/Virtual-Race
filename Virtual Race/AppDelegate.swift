//
//  AppDelegate.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/7/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let stack = CoreDataStack(modelName: "Model")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.orange
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().clipsToBounds = false
        
    //    UserDefaults.standard.removeObject(forKey: "Access Token")
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
         UserDefaults.standard.set(true, forKey: "refresh")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kCloseSafariViewControllerNotification), object: url)
 
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("eeee")
        
        if Reachability.isConnectedToNetwork() {
        
        let fr = NSFetchRequest<Match>(entityName: "Match")
        fr.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        fr.sortDescriptors = [NSSortDescriptor(key: "finished", ascending: true)]
        
        let predicate = NSPredicate(format: "myID = %@", argumentArray: [UserDefaults.standard.object(forKey: "myID")!])
        
        fr.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("could not perform fetch")
        }
        
        for objects in fetchedResultsController.fetchedObjects! {
            
            let match = objects
            
            if match.oppID != nil && match.started == true && match.finishDate == nil {
                
                let date = Date()
                
                if match.startDate!.compare(date) == ComparisonResult.orderedAscending {
                    
                    let newDistance = RetrieveDistance()
                    newDistance.getDistance(formatDate(match.startDate!)){ (result, error) in
                        
                        guard (error == nil) else {
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
                            }
                            match.myDistance = raceLocation.distance as NSNumber?
                        }

                        let defaultContainer = CKContainer.default()
                        
                        let publicDB = defaultContainer.publicCloudDatabase
                        
                        publicDB.fetch(withRecordID: match.recordID!) { (record, error) -> Void in
                            guard let record = record else {
                                print("Error fetching record: ", error)
                                return
                            }
                            
                            if isICloudContainerAvailable() {
                                
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
                                    
                                    performFetchWithCompletionHandler(UIBackgroundFetchResult.newData)
                                })
                                
                            } else {
                                print("no icloud account")
                            }
                        }
                    }
                }
            }
        }
        
        performFetchWithCompletionHandler(UIBackgroundFetchResult.noData)
        
        return
    }
    }
}

