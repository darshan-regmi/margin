import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

final class AuthService: ObservableObject {
    static let shared = AuthService()
    private init() {}

    @Published var user: User?
    private var authStateListener: AuthStateDidChangeListenerHandle?

    // MARK: - Configure auth listener
    func configure() {
        user = Auth.auth().currentUser
        authStateListener = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
            }
        }
    }

    // MARK: - Sign in with Google
    func signInWithGoogle(presenting windowScene: UIWindowScene) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // ✅ CRITICAL: Set the configuration
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        // Get root UIViewController
        guard let rootVC = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            if let error = error {
                print("Google Sign-In error:", error.localizedDescription)
                return
            }

            guard let user = signInResult?.user else {
                print("Google Sign-In failed: missing user")
                return
            }

            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken!,
                accessToken: accessToken
            )

            // Firebase sign-in
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in error:", error.localizedDescription)
                } else {
                    print("User signed in UID:", authResult?.user.uid ?? "")
                }
            }
        }
    }

    // MARK: - Sign out
    func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        DispatchQueue.main.async {
            self.user = nil
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
