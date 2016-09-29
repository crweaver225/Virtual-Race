//
//  CheckiCloud.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/14/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation



func isICloudContainerAvailable()->Bool {
    if let currentToken = FileManager.default.ubiquityIdentityToken {
        return true
    }
    else {
        return false
    }
}
