//
//  ContentView.swift
//  CustomTextMenuDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @State private var text: String = "Select some text and try the context menu!\n\nAvailable actions:\n- Print to Console\n- Make Uppercase\n- Count Words\n- Copy Selected Range\n- Share Text"
    @State private var selectedRange: NSRange?
    @State private var wordCount: Int = 0
    @State private var showShareSheet: Bool = false
    @State private var textToShare: String = ""
    
    private var customMenuActions: [CustomMenuAction] {
        [
            CustomMenuAction(
                id: "uppercase",
                title: "Print Uppercase",
                systemImage: "textformat.size"
            ) { text in
                print("Uppercase: \(text.uppercased())")
            },
            
            CustomMenuAction(
                id: "wordCount",
                title: "Count Words",
                systemImage: "number"
            ) { text in
                self.wordCount = text.split(separator: " ").count
                showWordCountAlert = true
            },
            
            CustomMenuAction(
                id: "copyRange",
                title: "Copy Selected Range",
                systemImage: "doc.on.doc"
            ) { text in
                UIPasteboard.general.string = text
            },
            
            CustomMenuAction(
                id: "share",
                title: "Share Text",
                systemImage: "square.and.arrow.up"
            ) { text in
                self.textToShare = text
                self.showShareSheet = true
            }
        ]
    }
    
    @State private var showWordCountAlert: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                CustomTextView(
                    text: $text,
                    customMenuActions: customMenuActions,
                    disabledMenuItems: [#selector(UIResponderStandardEditActions.cut(_:))]
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                statsView
            }
            .padding()
            .navigationTitle("Custom Text Editor")
            .alert("Word Count", isPresented: $showWordCountAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Selected text contains \(wordCount) words")
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(text: textToShare)
            }
        }
    }
    
    // MARK: - Supporting Views
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Characters")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(text.count)")
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Total Words")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(text.split(separator: " ").count)")
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Total Lines")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(text.split(separator: "\n").count)")
                        .font(.title2)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
