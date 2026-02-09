//
//  NoteEditorView.swift
//  Margin
//
//  Created by Darshan Regmi on 09/02/2026.
//


import SwiftUI
import CoreData

struct NoteEditorView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: 0) {
            TextField(
                "Title",
                text: Binding(
                    get: { note.title ?? "" },
                    set: {
                        note.title = $0
                        updateDate()
                    }
                )
            )
            .font(.title2)
            .padding()
            .textFieldStyle(.plain)

            Divider()

            TextEditor(
                text: Binding(
                    get: { note.content ?? "" },
                    set: {
                        note.content = $0
                        updateDate()
                    }
                )
            )
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func updateDate() {
        note.updatedAt = Date()
        try? viewContext.save()
    }
}
