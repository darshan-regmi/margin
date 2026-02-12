import SwiftUI

struct SignInView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Margin")
                .font(.largeTitle.bold())

            Button {
                if let windowScene = UIApplication.shared
                    .connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    AuthService.shared.signInWithGoogle(presenting: windowScene)
                }
            } label: {
                Label("Continue with Google", systemImage: "g.circle")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
