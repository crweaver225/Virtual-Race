//
//  Match.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/8/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import CoreData


class Match: NSManagedObject {
    
    convenience init(startDate: Date, myID: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Match", in: context){
            print("iii")
            self.init(entity: ent, insertInto: context)
            self.startDate = startDate
            self.myID = myID
        } else {
            fatalError("Unable to find Entity Name!")
        }
    }


}
