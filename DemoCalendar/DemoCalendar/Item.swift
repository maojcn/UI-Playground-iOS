//
//  Item.swift
//  DemoCalendar
//
//  Created by Jiacheng Mao on 06.04.25.
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
