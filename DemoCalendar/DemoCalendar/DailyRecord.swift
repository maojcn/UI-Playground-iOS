//
//  DailyRecord.swift
//  DemoCalendar
//
//  Created by Jiacheng Mao on 06.04.25.
//

import SwiftData
import Foundation

@Model
class DailyRecord {
    var date: Date // 存储日期（精确到天）
    var isCompleted: Bool // 是否完成
    
    init(date: Date, isCompleted: Bool = false) {
        self.date = date
        self.isCompleted = isCompleted
    }
    
    // 标准化日期（忽略时间部分）
    static func normalizedDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
}
