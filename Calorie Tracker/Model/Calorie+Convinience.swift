//
//  Calorie+Convinience.swift
//  Calorie Tracker
//
//  Created by Ilgar Ilyasov on 10/26/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Calorie {
    
    convenience init(amount: Int16, timestamp: Date = Date(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.amount = amount
        self.timestamp = timestamp
    }
    
    convenience init?(calorieRepresentation: CalorieRepresentation, context: NSManagedObjectContext) {
        self.init(amount: Int16(calorieRepresentation.amount), timestamp: calorieRepresentation.timestamp, context: context)
    }
}
