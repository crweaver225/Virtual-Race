//
//  LoginViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/26/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit
import SafariServices


let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class LoginViewController: ViewControllerMethods, SFSafariViewControllerDelegate {
    
    let authURL = URL(string: "https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=227ST9&scope=activity%20profile%20social&expires_in=31536000&prompt=consent")
    
    var safariVC: SFSafariViewController!
    
    @IBAction func permitAccess(_ sender: AnyObject) {
        
        openSafari()
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.safariLogin(_:)), name: NSNotification.Name(rawValue: kCloseSafariViewControllerNotification), object: nil)
        
    }
    
    func openSafari() {
        
        safariVC = SFSafariViewController(url: authURL!)
        
        self.present(safariVC!, animated: true, completion: nil)
        
    }
    
    func safariLogin(_ notification: Notification) {
        
        let url = notification.object as! URL
        
        let urlAuthorizationCode = String(describing: url)
        
        let findStartingIndex = urlAuthorizationCode.range(of: "=")
        
        let startingIndex = findStartingIndex?.upperBound
        
        let modifiedURLAuthorizationCode = urlAuthorizationCode.substring(from: startingIndex!)
        
        let findEndingIndex = modifiedURLAuthorizationCode.range(of: "&")
        
        let endingIndex = findEndingIndex?.lowerBound
        
        let authorizationCode = modifiedURLAuthorizationCode.substring(to: endingIndex!)
        
        UserDefaults.standard.set(authorizationCode, forKey: "Access Token")
        
        let dataRet = RetrieveAccessToken()
        dataRet.retrieveData() { (success, error) in
            
            guard (error == nil) else {
                if error as? Int == 001 {
                    self.displayAlert("No internet connection")
                }else {
                    self.displayAlert("There was a problem accessing the fitbit servers, please try again later")
                }
                return
            }
            
            if (success != nil) {
                
                UserDefaults.standard.set(true, forKey: "refresh")
                
                performUIUpdatesOnMain{
                    
                    self.dismiss(animated: false, completion: nil)
                    
                    let controller: UINavigationController
                    controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    
                    self.present(controller, animated: true, completion: nil)
                    
                }
            }
        }
    }
}
