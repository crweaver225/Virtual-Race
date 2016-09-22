//
//  GCDBlackbox.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/5/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}
