import SwiftUI

struct ContentView: View {
    @State private var notes: [Note] = []
    @State private var selectedNote: Note?
    @State private var searchText: String = ""

    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredNotes) { note in
                    NavigationLink(value: note) {
                        VStack(alignment: .leading, spacing: 4) {
                            HighlightedText(
                                text: note.title,
                                searchText: searchText
                            )
                            .font(.headline)
                            .lineLimit(1)
                            
                            HighlightedText(
                                text: searchText.isEmpty ? note.content : getRelevantSnippet(from: note.content),
                                searchText: searchText
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Margin")
            .searchable(text: $searchText, prompt: "Search notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        NotesService.shared.createNote { newNote in
                            selectedNote = newNote
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear {
                NotesService.shared.fetchNotes { fetched in
                    notes = fetched
                }
            }
            .navigationDestination(for: Note.self) { note in
                NoteEditorView(note: note)
            }
            .navigationDestination(item: $selectedNote) { note in
                NoteEditorView(note: note)
            }
        }
    }

    private func getRelevantSnippet(from content: String) -> String {
        guard !searchText.isEmpty else { return content }
        
        let lowercasedContent = content.lowercased()
        let lowercasedSearch = searchText.lowercased()
        
        guard let range = lowercasedContent.range(of: lowercasedSearch) else {
            return content
        }
        
        // Split content into lines
        let lines = content.components(separatedBy: .newlines)
        let lowercasedLines = lines.map { $0.lowercased() }
        
        // Find which line contains the match
        var lineIndex = 0
        for (index, line) in lowercasedLines.enumerated() {
            if line.contains(lowercasedSearch) {
                lineIndex = index
                break
            }
        }
        
        // Get context: the matching line plus one line before and after
        let startLine = max(0, lineIndex - 1)
        let endLine = min(lines.count - 1, lineIndex + 1)
        
        var snippet = lines[startLine...endLine].joined(separator: " ")
        
        // If the snippet is too long, trim it around the match
        if snippet.count > 150 {
            let lowercasedSnippet = snippet.lowercased()
            if let matchRange = lowercasedSnippet.range(of: lowercasedSearch) {
                let matchPosition = lowercasedSnippet.distance(from: lowercasedSnippet.startIndex, to: matchRange.lowerBound)
                let snippetRadius = 60
                
                let startIndex = snippet.index(snippet.startIndex, offsetBy: max(0, matchPosition - snippetRadius), limitedBy: snippet.endIndex) ?? snippet.startIndex
                let endIndex = snippet.index(snippet.startIndex, offsetBy: min(snippet.count, matchPosition + searchText.count + snippetRadius), limitedBy: snippet.endIndex) ?? snippet.endIndex
                
                snippet = String(snippet[startIndex..<endIndex])
                
                if startIndex != snippet.startIndex {
                    snippet = "..." + snippet
                }
                if endIndex != snippet.endIndex {
                    snippet = snippet + "..."
                }
            }
        }
        
        // Add ellipsis if we're not showing the beginning
        if startLine > 0 && !snippet.hasPrefix("...") {
            snippet = "..." + snippet
        }
        if endLine < lines.count - 1 && !snippet.hasSuffix("...") {
            snippet = snippet + "..."
        }
        
        return snippet
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach {
            NotesService.shared.deleteNote(id: filteredNotes[$0].id)
        }
    }
}

// MARK: - Highlighted Text View
struct HighlightedText: View {
    let text: String
    let searchText: String
    
    var body: some View {
        if searchText.isEmpty {
            Text(text)
        } else {
            Text(highlightedAttributedString)
        }
    }
    
    private var highlightedAttributedString: AttributedString {
        var attributedString = AttributedString(text)
        
        guard !searchText.isEmpty else {
            return attributedString
        }
        
        let lowercasedText = text.lowercased()
        let lowercasedSearch = searchText.lowercased()
        
        var searchStartIndex = lowercasedText.startIndex
        
        while let range = lowercasedText.range(of: lowercasedSearch, range: searchStartIndex..<lowercasedText.endIndex) {
            let startIndex = AttributedString.Index(range.lowerBound, within: attributedString)!
            let endIndex = AttributedString.Index(range.upperBound, within: attributedString)!
            
            attributedString[startIndex..<endIndex].backgroundColor = .yellow
            attributedString[startIndex..<endIndex].foregroundColor = .black
            
            searchStartIndex = range.upperBound
        }
        
        return attributedString
    }
}
