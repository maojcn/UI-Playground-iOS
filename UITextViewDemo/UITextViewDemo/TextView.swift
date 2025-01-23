//
//  TextView.swift
//  UITextViewDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    @Binding var text: String
    var font: UIFont?
    var foregroundColor: UIColor?
    var backgroundColor: UIColor?
    var isEditable: Bool = true
    var onTextChange: ((String) -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font ?? .systemFont(ofSize: 14)
        textView.textColor = foregroundColor ?? .black
        textView.backgroundColor = backgroundColor ?? .clear
        textView.isEditable = isEditable
        textView.isScrollEnabled = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = font ?? .systemFont(ofSize: 14)
        uiView.textColor = foregroundColor ?? .black
        uiView.backgroundColor = backgroundColor ?? .clear
        uiView.isEditable = isEditable
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        
        init(_ textView: TextView) {
            self.parent = textView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.onTextChange?(textView.text)
        }
    }
}

#Preview {
    TextView(text: .constant("Demo"))
}
