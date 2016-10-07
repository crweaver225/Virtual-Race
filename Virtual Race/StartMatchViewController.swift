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
    
    var friendList = [[String:Any]]()
    
    var checkerList = [[String:Any]]()
    
    var imageList = [Data]()
    
    override func viewWillAppear(_ animated:Bool) {
        
        super.viewWillAppear(animated)
        
        self.activityIndicator.startAnimating()
        
        let friends = retrieveFBFriends()
        
        friends.getFriends() { (friendsList, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    UserDefaults.standard.removeObject(forKey: "Access Token")
                    
                    let controller: MainPageViewController
                    controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                    
                    performUIUpdatesOnMain{
                        self.present(controller, animated: false, completion: nil)
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
            
            let avatar = String(describing: UserDefaults.standard.url(forKey: "avatar")!)
            
            let encodedID = UserDefaults.standard.object(forKey: "myID") as! String
            
            self.friendList.insert((["user": ["avatar": avatar as AnyObject, "displayName" : "Start a new race with yourself" as AnyObject, "encodedId": encodedID as AnyObject]]), at: 0)
            
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
            
            let avatarURL = URL(string: avatar)
            
            let avatarImage = try? Data(contentsOf: (avatarURL)!)
            
            self.imageList.append(avatarImage!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "startRace")!
        
        let row = friendList[(indexPath as NSIndexPath).row]
        
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
        
        cell.imageView!.image = UIImage(data: self.imageList[(indexPath as NSIndexPath).row])
        
        cell.textLabel?.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = friendList[(indexPath as NSIndexPath).row]
        
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
            controller = self.storyboard!.instantiateViewController(withIdentifier: "ChooseRouteViewController") as! ChooseRouteViewController
            controller.oppName = name
            controller.oppAvatar = self.imageList[(indexPath as NSIndexPath).row]
            controller.oppID = encodedID
            
            self.navigationController!.pushViewController(controller, animated: true)
            
        } else {
            
            let iCloudAlert = UIAlertController(title: "Action Denied", message: "Your IOS device must be signed into an iCloud account in order to create a new race. Exit the Virtual Race app > go to settings > sign into your iCloud > make sure Virtual Race has permission to use your iCloud account in the iCloud Drive settings. Virtual Race will not store any data on user's personal iCloud accounts.", preferredStyle: UIAlertControllerStyle.alert)
            
            iCloudAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(iCloudAlert, animated: true, completion: nil)
        }
    }
}
