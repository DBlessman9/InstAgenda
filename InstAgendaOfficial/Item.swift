//
//  Item.swift
//  InstAgendaOfficial
//
//  Created by Derald Blessman on 2/21/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
