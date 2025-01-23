# SwiftUI UITextView Wrapper

A customizable SwiftUI wrapper for UIKit's UITextView, providing rich text editing capabilities within SwiftUI applications.

## Features

- Two-way binding for text content
- Customizable appearance (font, colors, etc.)
- Text change callback support
- Scroll functionality
- Editable/read-only mode support

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.3+

## Installation

1. Add the `TextView.swift` file to your Xcode project
2. Make sure the file is included in your target

## Usage

### Basic Implementation

```swift
struct ContentView: View {
    @State private var text: String = "Initial text..."
    
    var body: some View {
        TextView(text: $text)
            .frame(height: 200)
    }
}
```

### Advanced Implementation

```swift
struct ContentView: View {
    @State private var text: String = "Enter your text here..."
    
    var body: some View {
        TextView(
            text: $text,
            font: .systemFont(ofSize: 16),
            foregroundColor: .black,
            backgroundColor: .white,
            isEditable: true,
            onTextChange: { newText in
                print("Text changed to: \(newText)")
            }
        )
        .frame(height: 200)
        .border(Color.gray)
        .padding()
    }
}
```

## Customization Options

### Font

```swift
TextView(text: $text, font: .systemFont(ofSize: 18, weight: .bold))
```

### Colors

```swift
TextView(
    text: $text,
    foregroundColor: .blue,
    backgroundColor: .lightGray
)
```

### Editability

```swift
TextView(text: $text, isEditable: false)
```

### Text Change Callback

```swift
TextView(
    text: $text,
    onTextChange: { newText in
        // Handle text changes
        saveText(newText)
    }
)
```

## Properties

| Property | Type | Description |
|----------|------|-------------|
| text | Binding<String> | Two-way binding for the text content |
| font | UIFont? | Optional font configuration |
| foregroundColor | UIColor? | Optional text color |
| backgroundColor | UIColor? | Optional background color |
| isEditable | Bool | Controls whether the text can be edited |
| onTextChange | ((String) -> Void)? | Optional callback for text changes |

## Best Practices

1. **Memory Management**: The wrapper handles memory management automatically through SwiftUI's view lifecycle.

2. **Text Updates**: Use the `onTextChange` callback for immediate text change notifications rather than watching the binding directly.

3. **Sizing**: Always provide a frame for the TextView to ensure proper sizing within your layout.

4. **Keyboard Handling**: Consider implementing keyboard avoidance if the TextView is used in a form or scrolling context.

## Common Issues and Solutions

### Issue: Text Not Updating

Make sure you're using a proper binding and the text state is properly initialized:

```swift
@State private var text: String = ""  // Initialize properly
```

### Issue: Keyboard Covering TextView

Implement keyboard avoidance:

```swift
.padding(.bottom, keyboard.currentHeight)  // Use with keyboard observer
```
