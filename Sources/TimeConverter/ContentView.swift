import SwiftUI
import AppKit

struct SelectableTextView: NSViewRepresentable {
    let text: String
    
    class Coordinator: NSObject {
        var parent: SelectableTextView
        
        init(_ parent: SelectableTextView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class CustomTextView: NSTextView {
        override func performKeyEquivalent(with event: NSEvent) -> Bool {
            if event.modifierFlags.contains(.command) {
                switch event.charactersIgnoringModifiers {
                case "c":
                    if let editor = window?.firstResponder as? NSTextView,
                       editor == self {
                        NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self)
                        return true
                    }
                case "a":
                    if let editor = window?.firstResponder as? NSTextView,
                       editor == self {
                        NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: self)
                        return true
                    }
                default:
                    break
                }
            }
            return super.performKeyEquivalent(with: event)
        }
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = CustomTextView()
        
        // Basic setup
        textView.string = text
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.backgroundColor = .textBackgroundColor
        
        // Make text view accept first responder status
        textView.allowsUndo = true
        
        // Configure text container
        if let container = textView.textContainer {
            container.containerSize = NSSize(width: scrollView.bounds.width, height: .greatestFiniteMagnitude)
            container.widthTracksTextView = true
        }
        
        // Configure layout manager
        textView.layoutManager?.allowsNonContiguousLayout = false
        
        // Configure scroll view
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.documentView = textView
        
        // Set text view frame
        textView.frame = scrollView.bounds
        textView.autoresizingMask = [.width]
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CustomTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }
}

struct ShortcutTextField: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    class Coordinator: NSObject {
        var parent: ShortcutTextField
        
        init(_ parent: ShortcutTextField) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class CustomTextField: NSTextField {
        override func performKeyEquivalent(with event: NSEvent) -> Bool {
            if event.modifierFlags.contains(.command) {
                switch event.charactersIgnoringModifiers {
                case "v":
                    if let editor = currentEditor() {
                        editor.paste(nil)
                        return true
                    }
                case "a":
                    if let editor = currentEditor() {
                        editor.selectAll(nil)
                        return true
                    }
                case "c":
                    if let editor = currentEditor() {
                        editor.copy(nil)
                        return true
                    }
                case "x":
                    if let editor = currentEditor() {
                        editor.cut(nil)
                        return true
                    }
                default:
                    break
                }
            }
            return super.performKeyEquivalent(with: event)
        }
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = CustomTextField()
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.bezelStyle = .roundedBezel
        textField.font = .systemFont(ofSize: NSFont.systemFontSize)
        
        // Enable standard edit menu
        textField.isEditable = true
        textField.isSelectable = true
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
}

extension ShortcutTextField.Coordinator: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            parent.text = textField.stringValue
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TimeConverterViewModel()
    @FocusState private var isInputFocused: Bool
    
    private let inputExamples = """
        Examples:
        • Timestamp: 1709913000 (seconds)
        • Timestamp: 1709913000000000 (microseconds)
        • Timestamp: 1709913000000000000 (nanoseconds)
        • DateTime: 2024-03-15
        • DateTime: 2024-03-15 14
        • DateTime: 2024-03-15 14:30
        • DateTime: 2024-03-15 14:30:45
        """
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Time Converter")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 4) {
                ShortcutTextField(
                    text: $viewModel.inputText,
                    placeholder: "Enter timestamp or datetime"
                )
                .frame(maxWidth: .infinity)
                
                Text(inputExamples)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            HStack {
                Text("Timezone:")
                Picker("", selection: $viewModel.selectedTimeZone) {
                    ForEach(viewModel.availableTimeZones, id: \.self) { timezone in
                        Text(timezone.identifier)
                            .tag(timezone)
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                viewModel.convert()
                isInputFocused = false
            }) {
                Text("Convert")
                    .frame(width: 100)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: [])
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if !viewModel.result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Result:")
                        Spacer()
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(viewModel.result, forType: .string)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy")
                                Text("(⌘C)")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.borderless)
                        .help("Copy result to clipboard (⌘C)")
                    }
                    
                    SelectableTextView(text: viewModel.result)
                        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(4)
                }
                .padding(.horizontal)
            }
            
            Spacer(minLength: 0)
        }
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif 