//
//  CustomMenuHostView.swift
//  CustomMenuDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//

import SwiftUI


class CustomMenuHostView: UIView, UIEditMenuInteractionDelegate {
    private var menuInteraction: UIEditMenuInteraction?
    var menuActions: [CustomMenuView.MenuAction] = []
    var onMenuItemSelected: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMenuInteraction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMenuInteraction()
    }
    
    private func setupMenuInteraction() {
        menuInteraction = UIEditMenuInteraction(delegate: self)
        if let menuInteraction = menuInteraction {
            addInteraction(menuInteraction)
        }
        
        // Add long press gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: self)
            presentEditMenu(at: location)
        }
    }
    
    private func presentEditMenu(at location: CGPoint) {
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
        menuInteraction?.presentEditMenu(with: configuration)
    }
    
    // UIEditMenuInteractionDelegate methods
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let menuActions = self.menuActions.map { menuAction in
            UIAction(
                title: menuAction.title,
                image: menuAction.image,
                attributes: menuAction.attributes
            ) { [weak self] _ in
                self?.onMenuItemSelected?(menuAction.title)
            }
        }
        
        return UIMenu(children: menuActions)
    }
}
