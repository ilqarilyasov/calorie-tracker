//
//  CalorieRepresentation.swift
//  Calorie Tracker
//
//  Created by Ilgar Ilyasov on 10/26/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

struct CalorieRepresentation {
    let amount: Int
    let timestamp: Date
    
    init(amount: Int, timestamp: Date = Date()) {
        self.amount = amount
        self.timestamp = timestamp
    }
}
