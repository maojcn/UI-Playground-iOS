//
//  ContentView.swift
//  UITextViewDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = "Enter your text here..."
        
        var body: some View {
            TextView(
                text: $text,
                font: .systemFont(ofSize: 16),
                foregroundColor: .black,
                backgroundColor: .white,
                onTextChange: { newText in
                    print("Text changed to: \(newText)")
                }
            )
            .frame(height: 200)
            .border(Color.gray)
            .padding()
        }
}

#Preview {
    ContentView()
}
