import FirebaseAuth
import Firebase

class UserStore: ObservableObject {
    @Published var displayName: String?
    @Published var email: String?
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        addAuthListener()
    }
    
    func addAuthListener() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.updateUserData()
        }
    }
    
    deinit {
        if let listenerHandle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }
    
    func updateUserData() {
        DispatchQueue.main.async { [weak self] in
            if let user = Auth.auth().currentUser {
                self?.displayName = user.displayName
                self?.email = user.email
            }
        }
    }
}

