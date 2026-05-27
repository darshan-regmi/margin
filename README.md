# Margin

A minimal iOS notes app built with SwiftUI, with Notion as the backend. Write, search, and preview Markdown notes with a clean native interface.

## Features

- Create, edit, and delete notes with auto-save (debounced)
- Full-text search with highlighted matches across title and content
- Markdown preview toggle in the editor
- Notion integration — notes sync to your Notion database
- Firebase / Google Sign-In authentication

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Backend**: Notion API
- **Auth**: Firebase Authentication (Google Sign-In)

## Prerequisites

- Xcode 15+
- iOS 17+ deployment target
- A Notion integration token and database ID
- A Firebase project with Google Sign-In enabled

## Setup

1. Clone the repository and open `Margin.xcodeproj` in Xcode.

2. Add your `GoogleService-Info.plist` (from Firebase Console) into the `Margin/` folder.

3. Configure your Notion credentials in the app — add your integration token and database ID to the relevant constants in `NotesService.swift`.

4. Build and run on an iOS Simulator or physical device.

## Project Structure

```
Margin/
├── MarginApp.swift          # App entry point
├── ContentView.swift        # Notes list with search
├── NoteEditorView.swift     # Editor with Markdown preview
├── Note.swift               # Note model
├── NotesService.swift       # Notion API integration
├── AuthService.swift        # Firebase auth
└── Debouncer.swift          # Save debouncer
```

## Running

Open `Margin.xcodeproj` in Xcode, select a simulator or device, and press Run (⌘R).
