import SwiftUI

struct NoteEditorView: View {
    @State var note: Note
    @FocusState private var isFocused: Bool
    @State private var preview: Bool = false

    private let debouncer = Debouncer()

    var body: some View {
        VStack(spacing: 0) {
            TextField("Title", text: $note.title)
                .font(.title2)
                .bold()
                .padding()
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onChange(of: note.title) { debouncedSave() }
            
            
            if preview {
                MarkdownView(text: note.content)
                    .padding()
            } else {
                TextEditor(text: $note.content)
                    .padding()
                    .focused($isFocused)
                    .onChange(of: note.content) { debouncedSave() }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    preview.toggle()
                } label: {
                    Image(systemName: preview ? "pencil" : "eye")
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: isFocused) {
            if !isFocused { save() }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            let isTitleEmpty = note.title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
            
            let isContentEmpty = note.content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
            
            if isTitleEmpty && isContentEmpty {
                NotesService.shared.deleteNote(id: note.id)
            }
        }
    }
    private func debouncedSave() {
        debouncer.debounce { save() }
    }

    private func save() {
        note.updatedAt = Date()
        NotesService.shared.updateNote(note)
    }
}

struct MarkdownView: View {
    let text: String

    var body: some View {
        if let attributed = try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            Text(attributed).font(.body)
        } else {
            Text(text).font(.body)
        }
    }
}
