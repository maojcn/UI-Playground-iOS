//
//  CollectionViewModel.swift
//  PostLanguage
//
//  Created by Jiacheng Mao on 2025/1/24.
//

import Foundation
import SwiftUI

// MARK: - View Model
class CollectionViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var translation: String = ""
    @Published var tags: [String] = []
    @Published var currentTag: String = ""
    @Published var sourceLanguage: Language = .english
    @Published var targetLanguage: Language = .japanese
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @MainActor
    func saveCollection() async {
        guard validateInput() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let collection = Collection(
                text: text,
                translation: translation,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                tags: Set(tags)
            )
//            try await collectionManager.createCollection(collection)
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addTag() {
        guard !currentTag.isEmpty,
              !tags.contains(currentTag),
              tags.count < 5 else { return }
        
        tags.append(currentTag)
        currentTag = ""
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func validateInput() -> Bool {
        guard !text.isEmpty else {
            errorMessage = "Please enter some text"
            return false
        }
        return true
    }
    
    private func resetForm() {
        text = ""
        translation = ""
        tags = []
        currentTag = ""
    }
}

// MARK: - Main View
struct CollectionCreateView: View {
    @StateObject private var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: CollectionViewModel = CollectionViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    LanguageSelectorView(
                        sourceLanguage: $viewModel.sourceLanguage,
                        targetLanguage: $viewModel.targetLanguage
                    )
                    
                    CollectionCardView(
                        text: $viewModel.text,
                        translation: $viewModel.translation,
                        tags: $viewModel.tags,
                        currentTag: $viewModel.currentTag,
                        onAddTag: viewModel.addTag,
                        onRemoveTag: viewModel.removeTag
                    )
                    
                    ActionButtonsView(onSave: {
                        Task {
                            await viewModel.saveCollection()
                            dismiss()
                        }
                    })
                }
                .padding()
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .background(.ultraThinMaterial)
                }
            }
        }
    }
}

// MARK: - Subcomponents
struct LanguageSelectorView: View {
    @Binding var sourceLanguage: Language
    @Binding var targetLanguage: Language
    
    var body: some View {
        HStack {
            Picker("From", selection: $sourceLanguage) {
                ForEach(Language.allCases) { language in
                    Text(language.displayName)
                        .tag(language)
                }
            }
            .pickerStyle(.menu)
            
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
            
            Picker("To", selection: $targetLanguage) {
                ForEach(Language.allCases) { language in
                    Text(language.displayName)
                        .tag(language)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.vertical, 8)
    }
}

struct CollectionCardView: View {
    @Binding var text: String
    @Binding var translation: String
    @Binding var tags: [String]
    @Binding var currentTag: String
    let onAddTag: () -> Void
    let onRemoveTag: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Text Input
            TextField("Enter text to learn...", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
            
            // Translation Input
            TextField("Add translation (optional)", text: $translation, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
            
            // Tags
            VStack(alignment: .leading, spacing: 8) {
                // Tag List
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagView(tag: tag) {
                            onRemoveTag(tag)
                        }
                    }
                }
                
                // Tag Input
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.secondary)
                    
                    TextField("Add tag", text: $currentTag)
                        .submitLabel(.done)
                        .onSubmit(onAddTag)
                    
                    if !currentTag.isEmpty {
                        Button(action: onAddTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2))
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.subheadline)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ActionButtonsView: View {
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "book")
                }
                Button(action: {}) {
                    Image(systemName: "globe")
                }
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                }
            }
            .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "bookmark")
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
                Button(action: onSave) {
                    Text("Save")
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layoutHelper(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layoutHelper(sizes: sizes, proposal: proposal).offsets
        
        for (offset, subview) in zip(offsets, subviews) {
//            subview.place(at: bounds.origin + offset, proposal: .unspecified)
        }
    }
    
    private func layoutHelper(sizes: [CGSize], proposal: ProposedViewSize) -> (size: CGSize, offsets: [CGPoint]) {
        let width = proposal.width ?? .infinity
        var offsets: [CGPoint] = []
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        for size in sizes {
            if currentPosition.x + size.width > width && currentPosition.x > 0 {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                totalHeight += lineHeight + spacing
                lineHeight = 0
            }
            
            offsets.append(currentPosition)
            currentPosition.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        totalHeight += lineHeight
        
        return (CGSize(width: width, height: totalHeight), offsets)
    }
}

// MARK: - Models
enum Language: String, CaseIterable, Identifiable {
    case english
    case japanese
    case german
    case spanish
    case french
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .japanese: return "Japanese"
        case .german: return "German"
        case .spanish: return "Spanish"
        case .french: return "French"
        }
    }
}

struct Collection {
    let id: UUID = UUID()
    let text: String
    let translation: String?
    let sourceLanguage: Language
    let targetLanguage: Language
    let tags: Set<String>
    let createdAt: Date = Date()
}

#Preview {
    CollectionCreateView(viewModel: CollectionViewModel())
}
