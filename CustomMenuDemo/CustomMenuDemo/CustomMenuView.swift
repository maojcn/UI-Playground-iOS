//
//  CustomMenuView.swift
//  CustomMenuDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//


import SwiftUI
import UIKit

struct CustomMenuView: UIViewRepresentable {
    let menuActions: [MenuAction]
    var onMenuItemSelected: (String) -> Void
    
    // Define menu action structure
    struct MenuAction {
        let title: String
        let image: UIImage?
        let attributes: UIMenuElement.Attributes
        
        init(title: String,
             image: UIImage? = nil,
             attributes: UIMenuElement.Attributes = []) {
            self.title = title
            self.image = image
            self.attributes = attributes
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = CustomMenuHostView()
        view.backgroundColor = .clear
        view.menuActions = menuActions
        view.onMenuItemSelected = onMenuItemSelected
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let customView = uiView as? CustomMenuHostView {
            customView.menuActions = menuActions
            customView.onMenuItemSelected = onMenuItemSelected
        }
    }
}
