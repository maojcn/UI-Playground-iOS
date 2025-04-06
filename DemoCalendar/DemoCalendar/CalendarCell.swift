//
//  CalendarCell.swift
//  DemoCalendar
//
//  Created by Jiacheng Mao on 06.04.25.
//

import SwiftUI

struct CalendarCell: View {
    let date: Date
    let isCompleted: Bool
    let onTap: () -> Void
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(date, equalTo: date, toGranularity: .month)
    }
    
    var body: some View {
        Text(dayNumber)
            .frame(width: 30, height: 30)
            .background(isCompleted ? Color.green : Color.gray.opacity(0.2))
            .clipShape(Circle())
            .foregroundColor(isCurrentMonth ? .primary : .secondary)
            .onTapGesture(perform: onTap)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarCell(date: Date(), isCompleted: true) {
        print("Tapped")
    }
    .padding()
}
