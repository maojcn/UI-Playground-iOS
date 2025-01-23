//
//  ContentView.swift
//  CustomMenuDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//

import SwiftUI

struct ContentView: View {
    let menuActions = [
        CustomMenuView.MenuAction(
            title: "Copy",
            image: UIImage(systemName: "doc.on.doc"),
            attributes: []
        ),
        CustomMenuView.MenuAction(
            title: "Share",
            image: UIImage(systemName: "square.and.arrow.up"),
            attributes: []
        ),
        CustomMenuView.MenuAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        )
    ]
    
    var body: some View {
        CustomMenuView(menuActions: menuActions) { selectedItem in
            print("Selected menu item: \(selectedItem)")
            // Handle menu item selection
            switch selectedItem {
            case "Copy":
                UIPasteboard.general.string = "Copied text"
            case "Share":
                // Handle share action
                break
            case "Delete":
                // Handle delete action
                break
            default:
                break
            }
        }
        .frame(width: 200, height: 200)
        .background(Color.blue.opacity(0.2))
    }
}

#Preview {
    ContentView()
}
