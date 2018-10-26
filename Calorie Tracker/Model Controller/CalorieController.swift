//
//  CalorieController.swift
//  Calorie Tracker
//
//  Created by Ilgar Ilyasov on 10/26/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CalorieController {
    
    var calories: [Calorie] = []
    
    func addCalorie(amount: Int) {
        let calorie = Calorie(amount: Int16(amount))
        calories.append(calorie)
        
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving data to persistent store: \(error)")
        }
    }
    
}
