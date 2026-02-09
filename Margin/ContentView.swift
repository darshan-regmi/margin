//
//  ContentView.swift
//  Margin
//
//  Created by Darshan Regmi on 09/02/2026.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)],
        animation: .default
    )
    private var notes: FetchedResults<Note>

    @State private var selectedNote: Note?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedNote) {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title ?? "Untitled")
                            .font(.headline)
                            .lineLimit(1)

                        Text(note.content ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 6)
                    .tag(note)
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Margin")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addNote) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        } detail: {
            if let note = selectedNote {
                NoteEditorView(note: note)
            } else {
                Text("Write something in the margin.")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
        }
    }

    private func addNote() {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.id = UUID()
            newNote.title = "Untitled"
            newNote.content = ""
            newNote.createdAt = Date()
            newNote.updatedAt = Date()

            saveContext()
            selectedNote = newNote
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}
