//
//  CalendarView.swift
//  DemoCalendar
//
//  Created by Jiacheng Mao on 06.04.25.
//

import SwiftUI
import SwiftData
import Foundation

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [DailyRecord] // 自动查询数据
    
    @State private var currentDate = Date() // 当前显示的月份
    
    // 月份切换逻辑
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        currentDate = calendar.date(byAdding: .month, value: value, to: currentDate)!
    }
    
    var body: some View {
        VStack {
            // 月份导航栏
            HStack {
                Button("←") { changeMonth(by: -1) }
                Text(currentDate, format: .dateTime.year().month(.wide))
                Button("→") { changeMonth(by: 1) }
            }
            
            // 日历网格
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(datesInMonth(), id: \.self) { date in
                    CalendarCell(
                        date: date,
                        isCompleted: isDateCompleted(date),
                        onTap: { toggleCompletion(for: date) }
                    )
                }
            }
        }
        .padding()
    }
    
    // 检查某天是否完成
    private func isDateCompleted(_ date: Date) -> Bool {
        let normalized = DailyRecord.normalizedDate(date)
        return records.contains { DailyRecord.normalizedDate($0.date) == normalized && $0.isCompleted }
    }
    
    // 切换完成状态
    private func toggleCompletion(for date: Date) {
        let normalized = DailyRecord.normalizedDate(date)
        
        if let existingRecord = records.first(where: { DailyRecord.normalizedDate($0.date) == normalized }) {
            existingRecord.isCompleted.toggle()
        } else {
            let newRecord = DailyRecord(date: normalized, isCompleted: true)
            modelContext.insert(newRecord)
        }
    }
    
    // 生成当前月份所有日期（含填充）
    private func datesInMonth() -> [Date] {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        // 计算填充空白（例如：6月1日是周四，则前面补3天空单元格）
        let startOffset = calendar.component(.weekday, from: monthStart) - calendar.firstWeekday
        let startDate = calendar.date(byAdding: .day, value: -startOffset, to: monthStart)!
        
        // 生成日期数组（通常6周足够覆盖月份）
        return (0..<42).compactMap { 
            calendar.date(byAdding: .day, value: $0, to: startDate) 
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: DailyRecord.self)
        .padding()
}
