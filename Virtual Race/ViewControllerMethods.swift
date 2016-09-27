//
//  ViewControllerMethods.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/26/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit


class ViewControllerMethods: UIViewController {
    
    func displayAlert(text: String) {
        let networkAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        networkAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        self.presentViewController(networkAlert, animated: true, completion: nil)
    }
}