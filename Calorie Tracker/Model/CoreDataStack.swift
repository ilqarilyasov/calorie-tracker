//
//  CoreDataStack.swift
//  Calorie Tracker
//
//  Created by Ilgar Ilyasov on 10/26/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Calorie Tracker" as String)
        container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true // Merge contexts
        return container
    }()
    
    var mainContext: NSManagedObjectContext { return container.viewContext }
}
