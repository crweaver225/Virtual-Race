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
    
    func displayAlert(_ text: String) {
        let networkAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        networkAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        self.present(networkAlert, animated: true, completion: nil)
    }
    
}
