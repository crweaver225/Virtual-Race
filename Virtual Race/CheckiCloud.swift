//
//  CheckiCloud.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/14/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation



func isICloudContainerAvailable()->Bool {
    if let currentToken = NSFileManager.defaultManager().ubiquityIdentityToken {
        print("icloud available")
        return true
    }
    else {
        print("icloud unavailable")
        return false
    }
}