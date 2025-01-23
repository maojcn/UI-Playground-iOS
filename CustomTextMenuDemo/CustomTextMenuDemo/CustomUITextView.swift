//
//  CustomUITextView.swift
//  CustomTextMenuDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//

import UIKit
import SwiftUI

// MARK: - CustomMenuAction
struct CustomMenuAction {
    let id: String
    let title: String
    let image: UIImage?
    let action: (String) -> Void
    
    init(id: String, title: String, systemImage: String? = nil, action: @escaping (String) -> Void) {
        self.id = id
        self.title = title
        self.image = systemImage.map { UIImage(systemName: $0)! }
        self.action = action
    }
}

// MARK: - CustomUITextView
final class CustomUITextView: UITextView {
    // MARK: - Properties
    private var customMenuActions: [CustomMenuAction] = []
    private var disabledDefaultMenuItems: Set<Selector> = []
    
    // MARK: - Public Configuration
    
    /// Adds a custom menu action to the text view's context menu
    /// - Parameter menuAction: The custom menu action to add
    func addMenuAction(_ menuAction: CustomMenuAction) {
        if !customMenuActions.contains(where: { $0.id == menuAction.id }) {
            customMenuActions.append(menuAction)
        }
    }
    
    /// Removes a custom menu action from the text view's context menu
    /// - Parameter actionId: The ID of the action to remove
    func removeMenuAction(withId actionId: String) {
        customMenuActions.removeAll { $0.id == actionId }
    }
    
    /// Disables a default menu item
    /// - Parameter selector: The selector of the menu item to disable
    func disableDefaultMenuItem(_ selector: Selector) {
        disabledDefaultMenuItems.insert(selector)
    }
    
    /// Enables a previously disabled default menu item
    /// - Parameter selector: The selector of the menu item to enable
    func enableDefaultMenuItem(_ selector: Selector) {
        disabledDefaultMenuItems.remove(selector)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextView()
    }
    
    // MARK: - Setup
    private func setupTextView() {
        isScrollEnabled = true
        isEditable = true
        isUserInteractionEnabled = true
        font = .preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        
        // Add default print action as an example
        addMenuAction(CustomMenuAction(
            id: "print",
            title: "Print to Console",
            systemImage: "printer") {selectedText in
                print(selectedText)
            }
        )
    }
}

// MARK: - Menu Configuration
extension CustomUITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Check if the action is disabled
        if disabledDefaultMenuItems.contains(action) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func editMenu(for textRange: UITextRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        guard let selectedText = text(in: textRange) else {
            return UIMenu(children: suggestedActions)
        }
        
        // Create UIActions from custom menu actions
        let customUIActions = customMenuActions.map { menuAction in
            UIAction(
                title: menuAction.title,
                image: menuAction.image
            ) { [weak self] _ in
                guard self != nil else { return }
                menuAction.action(selectedText)
            }
        }
        
        // Insert custom actions at the beginning of the menu
        var updatedActions = suggestedActions
        customUIActions.reversed().forEach { updatedActions.insert($0, at: 0) }
        
        return UIMenu(children: updatedActions)
    }
}

// MARK: - SwiftUI Wrapper
struct CustomTextView: UIViewRepresentable {
    // MARK: - Properties
    @Binding private var text: String
    private var customMenuActions: [CustomMenuAction]
    private var disabledMenuItems: Set<Selector>
    
    // MARK: - Initialization
    init(
        text: Binding<String>,
        customMenuActions: [CustomMenuAction] = [],
        disabledMenuItems: Set<Selector> = []
    ) {
        self._text = text
        self.customMenuActions = customMenuActions
        self.disabledMenuItems = disabledMenuItems
    }
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> CustomUITextView {
        let textView = CustomUITextView()
        
        // Configure custom menu actions
        customMenuActions.forEach { textView.addMenuAction($0) }
        
        // Configure disabled menu items
        disabledMenuItems.forEach { textView.disableDefaultMenuItem($0) }
        
        return textView
    }
    
    func updateUIView(_ uiView: CustomUITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}

// MARK: - Preview
#Preview {
    CustomTextView(
        text: .constant("Select some text and try the context menu!"),
        customMenuActions: [
            CustomMenuAction(
                id: "uppercase",
                title: "Print Uppercase",
                systemImage: "textformat.size"
            ) { text in
                print("Uppercase: \(text.uppercased())")
            },
            CustomMenuAction(
                id: "wordCount",
                title: "Word Count",
                systemImage: "number"
            ) { text in
                let words = text.split(separator: " ").count
                print("Word count: \(words)")
            }
        ],
        disabledMenuItems: [#selector(UIResponderStandardEditActions.cut(_:))]
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
}
