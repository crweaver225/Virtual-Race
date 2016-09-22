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

    convenience init(startDate: NSDate, myID: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Match", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.startDate = startDate
            self.myID = myID
        } else {
            fatalError("Unable to find Entity Name!")
        }
    }


}
