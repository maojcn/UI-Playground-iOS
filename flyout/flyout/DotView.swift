//
//  DotView.swift
//  flyout
//
//  Created by Jiacheng Mao on 05.04.25.
//


import SwiftUI

struct DotView: View {
    let totalDots = 365
    let dotsPerRow = 14
    let dotSize: CGFloat = 4
    let dotSpacing: CGFloat = 20
    
    @State private var selectedDate: Date? // Track the tapped dot's date
    @State private var showFlyout: Bool = false
    @State private var dotPositions: [Int: CGPoint] = [:]
    @State private var selectedDotIndex: Int = 0
    
    // Get current year's January 1st as starting date
    private var startDate: Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1)) ?? Date()
    }
    
    // Get date for a specific dot index
    private func date(for index: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: index, to: startDate) ?? Date()
    }
    
    var body: some View {
        let rows = 27
        
        ZStack {
            VStack(alignment: .leading, spacing: dotSpacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: dotSpacing) {
                        ForEach(0..<dotsInRow(row), id: \.self) { column in
                            let dotIndex = row * dotsPerRow + column
                            
                            DotWithPosition(index: dotIndex) { position in
                                dotPositions[dotIndex] = position
                            }
                            .frame(width: dotSize, height: dotSize)
                            .foregroundStyle(.tint)
                            .offset(y: column % 2 == 0 ? dotSize/2 : -dotSize/2)
                            .contentShape(Rectangle()) // Improve tap area
                            .onTapGesture {
                                selectedDotIndex = dotIndex
                                selectedDate = date(for: dotIndex)
                                showFlyout = true
                            }
                        }
                    }
                }
            }
            .padding()
            
            // Date Flyout
            if let selectedDate = selectedDate,
               showFlyout,
               let position = dotPositions[selectedDotIndex] {
                DateFlyout(
                    date: selectedDate,
                    position: position,
                    isShowing: $showFlyout
                )
            }
        }
    }
    
    func dotsInRow(_ row: Int) -> Int {
        let remainingDots = totalDots - row * dotsPerRow
        return min(dotsPerRow, remainingDots)
    }
}

struct DotWithPosition: View {
    let index: Int
    let onPositionChange: (CGPoint) -> Void
    
    var body: some View {
        Circle()
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            let center = CGPoint(
                                x: geometry.frame(in: .global).midX,
                                y: geometry.frame(in: .global).midY
                            )
                            onPositionChange(center)
                        }
                }
            )
    }
}

#Preview {
    DotView()
        .tint(.purple)
}
