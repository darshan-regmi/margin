import Foundation

struct Note: Identifiable, Hashable {
    let id: String
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
}
