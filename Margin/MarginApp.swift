import SwiftUI
import Firebase

@main
struct MarginApp: App {
    init() {
        FirebaseApp.configure()
        AuthService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @ObservedObject var auth = AuthService.shared
    
    var body: some View {
        if auth.user == nil {
            SignInView()
        } else {
            ContentView()
        }
    }
}
