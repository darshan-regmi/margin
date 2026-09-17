import FirebaseFirestore
import FirebaseAuth

final class NotesService {
    static let shared = NotesService()
    private init() {}

    private let db = Firestore.firestore()
    private var notesRef: CollectionReference {
        guard let uid = Auth.auth().currentUser?.uid else {
            fatalError("User not logged in")
        }
        return db.collection("users").document(uid).collection("notes")
    }

    func fetchNotes(completion: @escaping ([Note]) -> Void) {
        notesRef
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }

                let notes = docs.map { doc in
                    let data = doc.data()
                    return Note(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        content: data["content"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }

                DispatchQueue.main.async { completion(notes) }
            }
    }

    func createNote(completion: @escaping (Note) -> Void) {
        let ref = notesRef.document()

        let note = Note(
            id: ref.documentID,
            title: "",
            content: "",
            createdAt: Date(),
            updatedAt: Date()
        )

        // Navigate immediately
        DispatchQueue.main.async {
            completion(note)
        }

        // Save to Firestore in the background
        ref.setData([
            "title": note.title,
            "content": note.content,
            "createdAt": Timestamp(date: note.createdAt),
            "updatedAt": Timestamp(date: note.updatedAt)
        ])
    }

    func updateNote(_ note: Note) {
        notesRef.document(note.id).updateData([
            "title": note.title,
            "content": note.content,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func deleteNote(id: String) {
        notesRef.document(id).delete()
    }
}
