//
//  DateFlyout.swift
//  flyout
//
//  Created by Jiacheng Mao on 05.04.25.
//

import SwiftUI

struct DateFlyout: View {
    let date: Date
    let position: CGPoint
    @Binding var isShowing: Bool
    
    private let verticalOffset: CGFloat = -90
    private let flyoutWidth: CGFloat = 200
    private let flyoutHeight: CGFloat = 50

    // 日期格式化器
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        GeometryReader { geometry in
            Text(formatter.string(from: date))
                .font(.callout)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground)) // 背景色（适配暗黑模式）
                        .shadow(radius: 2)              // 添加阴影
                )
                .frame(width: flyoutWidth, height: flyoutHeight)
                .position(
                    x: adjustedXPosition(for: position.x, in: geometry.size.width),
                    y: adjustedYPosition(for: position.y + verticalOffset, in: geometry.size.height)
                )
                .transition(.opacity)  // 显示/隐藏时淡入淡出
                .onTapGesture {
                    isShowing = false  // 点击Flyout时隐藏
                }
                .onAppear {
                    // 3秒后自动隐藏
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isShowing = false
                    }
                }
        }
    }
    
    // Keep flyout within horizontal bounds
    private func adjustedXPosition(for x: CGFloat, in width: CGFloat) -> CGFloat {
        let halfFlyoutWidth = flyoutWidth / 3
        let minX = halfFlyoutWidth
        let maxX = width - halfFlyoutWidth
        
        return min(max(x, minX), maxX)
    }
    
    // Keep flyout within vertical bounds
    private func adjustedYPosition(for y: CGFloat, in height: CGFloat) -> CGFloat {
        let halfFlyoutHeight = flyoutHeight / 3
        let minY = halfFlyoutHeight
        let maxY = height - halfFlyoutHeight
        
        return min(max(y, minY), maxY)
    }
}

#Preview {
    DateFlyout(date: Date(), position: CGPoint(x: 0, y: 100), isShowing: .constant(true))
}
