//
//  StartMatchViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/7/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import CloudKit




class StartMatchViewController: ViewControllerMethods, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var friendList = [[String:AnyObject]]()
    
    var imageList = [NSData]()
    
    override func viewWillAppear(animated:Bool) {
        
        super.viewWillAppear(animated)
        
        self.activityIndicator.startAnimating()
        
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
                }else {
                    self.displayAlert("There was a problem accessing the fitbit servers, please try again later")
                    self.activityIndicator.stopAnimating()
                }
                
                return
            }

            self.friendList = friendsList!
            
            let avatar = String(NSUserDefaults.standardUserDefaults().URLForKey("avatar")!)
            
            let encodedID = NSUserDefaults.standardUserDefaults().objectForKey("myID") as! String
            
            self.friendList.insert((["user": ["avatar": avatar, "displayName" : "Start a new race with yourself", "encodedId": encodedID]]), atIndex: 0)
            
            if self.imageList.count != self.friendList.count {
                self.loadPictures()
            }
            
            performUIUpdatesOnMain{
                self.activityIndicator.stopAnimating()
                self.TableView.reloadData()
            }
        }
    }

    func loadPictures() {
        
        for image in friendList {
            
            guard let user = image["user"] as? [String:AnyObject] else {
                print("could not get user")
                return
            }
            
            guard let avatar = user["avatar"] as? String else {
                print("could not get avatar")
                return
            }
            
            let avatarURL = NSURL(string: avatar)
            
            let avatarImage = NSData(contentsOfURL: (avatarURL)!)
            
            self.imageList.append(avatarImage!)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120.0
    }
    
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friendList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("startRace")!
        
        let row = friendList[indexPath.row]
        
        guard let user = row["user"] as? [String:AnyObject] else {
            print("could not get user")
            return cell
        }
        
        guard let avatar = user["avatar"] as? String else {
            print("could not get avatar")
            return cell
        }
        
        guard let name = user["displayName"] as? String else {
            print("could not get name")
            return cell
        }
        
        guard let encodedID = user["encodedId"] as? String else {
            print("no encoded ID")
            return cell
        }
        
        cell.imageView!.image = UIImage(data: self.imageList[indexPath.row])
        
        cell.textLabel?.text = name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = friendList[indexPath.row]
        
        guard let user = row["user"] as? [String:AnyObject] else {
            print("could not get user")
            return
        }
        
        guard let name = user["displayName"] as? String else {
            print("could not get name")
            return
        }
        
        guard let encodedID = user["encodedId"] as? String else {
            print("no encoded ID")
            return
        }
        
        if isICloudContainerAvailable() {
            
            let controller: ChooseRouteViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseRouteViewController") as! ChooseRouteViewController
            controller.oppName = name
            controller.oppAvatar = self.imageList[indexPath.row]
            controller.oppID = encodedID
            
            self.navigationController!.pushViewController(controller, animated: true)
            
        } else {
            
            let iCloudAlert = UIAlertController(title: "Action Denied", message: "Your IOS device must be signed into an iCloud account in order to create a new race. Exit the Virtual Race app > go to settings > sign into your iCloud > make sure Virtual Race has permission to use your iCloud account in the iCloud Drive settings. Virtual Race will not store any data on user's personal iCloud accounts.", preferredStyle: UIAlertControllerStyle.Alert)
            
            iCloudAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            self.presentViewController(iCloudAlert, animated: true, completion: nil)
        }
    }
}