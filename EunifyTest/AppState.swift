import FirebaseAuth
import Firebase

class AppState: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var isLoggedIn: Bool = false

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isLoading = false
            self.isLoggedIn = user != nil
        }
    }
}
