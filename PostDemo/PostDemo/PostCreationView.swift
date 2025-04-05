//
//  PostCreationView.swift
//  PostDemo
//
//  Created by Jiacheng Mao on 2025/1/23.
//


import SwiftUI
import PhotosUI

struct PostCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPhotosItems: [PhotosPickerItem] = []
    @State private var showingTagSuggestions = false
    @State private var showingEmojiPicker = false
    @State private var isPosting = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Haptic feedback generator
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    // Sample tags with emoji - would come from backend
    let suggestedTags = [
        ("technology", "💻"), ("design", "🎨"),
        ("programming", "👨‍💻"), ("art", "🖼"),
        ("music", "🎵"), ("travel", "✈️")
    ]
    
    var canPost: Bool {
        !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // User Info Header
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.gray)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("What's happening?")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Text("Everyone")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // Text Input Area
                    TextEditor(text: $postText)
                        .frame(minHeight: 100)
                        .focused($isTextFieldFocused)
                        .onChange(of: postText) { newValue in
                            if newValue.count > 140 {
                                postText = String(newValue.prefix(140))
                                haptic.impactOccurred()
                            }
                            showingTagSuggestions = newValue.last == "#"
                        }
                        .font(.body)
                        .padding(.horizontal)
                    
                    // Image Grid
                    if !selectedImages.isEmpty {
                        ImageGridView(images: $selectedImages)
                            .padding(.top, 12)
                    }
                    
                    // Tag Suggestions
                    if showingTagSuggestions {
                        TagSuggestionsView(tags: suggestedTags) { tag, emoji in
                            insertTag(tag, emoji)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Divider()
                        .padding(.vertical, 12)
                    
                    // Bottom Toolbar
                    BottomToolbarView(
                        imageCount: selectedImages.count,
                        selectedPhotosItems: $selectedPhotosItems,
                        showingEmojiPicker: $showingEmojiPicker,
                        characterCount: postText.count
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        handlePost()
                    } label: {
                        Text("Post")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(canPost ? Color.accentColor : Color.gray.opacity(0.3))
                            .foregroundColor(canPost ? .white : .gray)
                            .cornerRadius(20)
                    }
                    .disabled(!canPost || isPosting)
                }
            }
        }
        .onChange(of: selectedPhotosItems) { items in
            Task {
                var images: [UIImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                        haptic.impactOccurred(intensity: 0.5)
                    }
                }
                selectedImages = images
            }
        }
    }
    
    private func insertTag(_ tag: String, _ emoji: String) {
        postText = postText.dropLast() + tag + " " + emoji + " "
        showingTagSuggestions = false
        haptic.impactOccurred(intensity: 0.6)
    }
    
    private func handlePost() {
        isPosting = true
        haptic.impactOccurred()
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isPosting = false
            dismiss()
        }
    }
}

// MARK: - Supporting Views

struct ImageGridView: View {
    @Binding var images: [UIImage]
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                imageCell(image: image, index: index)
            }
        }
        .padding(.horizontal)
    }
    
    private func imageCell(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if images.count > index {
                        images.remove(at: index)
                    }
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.black.opacity(0.5))
                    .padding(8)
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
}

struct TagSuggestionsView: View {
    let tags: [(String, String)]
    let onSelect: (String, String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(tags, id: \.0) { tag, emoji in
                    Button {
                        onSelect(tag, emoji)
                    } label: {
                        HStack(spacing: 4) {
                            Text("#\(tag)")
                            Text(emoji)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct BottomToolbarView: View {
    let imageCount: Int
    @Binding var selectedPhotosItems: [PhotosPickerItem]
    @Binding var showingEmojiPicker: Bool
    let characterCount: Int
    
    var body: some View {
        HStack {
            HStack(spacing: 20) {
                PhotosPicker(selection: $selectedPhotosItems,
                           maxSelectionCount: 6 - imageCount,
                           matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                .disabled(imageCount >= 6)
                
                Button {
                    showingEmojiPicker.toggle()
                } label: {
                    Image(systemName: "face.smiling")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                
                Button {
                    // Add location
                } label: {
                    Image(systemName: "location")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }
            
            Spacer()
            
            // Character count with circular progress
            ZStack {
                Circle()
                    .stroke(lineWidth: 2)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: 0.0, to: min(CGFloat(characterCount) / 140, 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundColor(characterCount > 115 ? (characterCount > 130 ? .red : .orange) : .accentColor)
                    .rotationEffect(Angle(degrees: -90))
                
                if characterCount > 0 {
                    Text("\(140 - characterCount)")
                        .font(.caption2)
                        .foregroundColor(characterCount > 115 ? (characterCount > 130 ? .red : .orange) : .secondary)
                }
            }
            .frame(width: 24, height: 24)
        }
        .padding(.horizontal)
    }
}

// Preview Provider
struct PostCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PostCreationView()
    }
}
