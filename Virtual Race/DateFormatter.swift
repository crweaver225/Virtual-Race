//
//  DateFormatter.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/12/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation


func formatDate(_ date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let convertedDate = dateFormatter.string(from: date)
    
    return convertedDate
}

func dateConverter(_ date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    
    let convertedDate = dateFormatter.date(from: date)
    
    return convertedDate!
}


