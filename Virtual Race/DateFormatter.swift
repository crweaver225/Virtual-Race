//
//  DateFormatter.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/12/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


func formatDate(date: NSDate) -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale.currentLocale()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let convertedDate = dateFormatter.stringFromDate(date)
    
    return convertedDate
}

func dateConverter(date: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    
    let convertedDate = dateFormatter.dateFromString(date)
    
    return convertedDate!
}