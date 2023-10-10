import SwiftUI
import FirebaseAuth
import Firebase


struct User {
    let name: String
    let email: String
    let password: String
}

class AuthManager {
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    
    func registerNewUser(with user: User, completion: @escaping (Bool, String?) -> Void) {
        // Check if email is valid
        guard user.email.contains("@pdsb.net") else {
            completion(false, "Email must end with @pdsb.net")
            return
        }
        
        // Create user in Firebase
        auth.createUser(withEmail: user.email, password: user.password) { authResult, error in
            guard let userResult = authResult, error == nil else {
                completion(false, error?.localizedDescription)
                return
            }
            
            // Update user's display name
            let changeRequest = userResult.user.createProfileChangeRequest()
            changeRequest.displayName = user.name
            changeRequest.commitChanges { [weak self] error in
                guard error == nil else {
                    completion(false, error?.localizedDescription)
                    return
                }
                
                Auth.auth().currentUser?.reload { error in
                    guard error == nil else {
                        completion(false, error?.localizedDescription)
                        return
                    }
                    self?.loginUser(with: user.email, password: user.password) { success in
                        completion(success, success ? nil : "Error logging in after registration")
                    }
                }
            }
        }
    }
    
    func loginUser(with email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            guard authResult != nil, error == nil else {
                completion(false)
                return
            }
            // Save login state
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            
            completion(true)
        }
    }
}



struct SignupView: View {
    @State private var schoolEmail: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var termsAccepted: Bool = false
    @State private var isSignupSuccessful = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack(spacing: 20) {
            
            Button(action: {
                // Handle Apple ID Sign Up
            }) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.title)
                    Text("Sign Up with Apple ID")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity) // Makes it full width
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            
            Text("OR")
                .fontWeight(.medium)
            
            TextField("School Email", text: $schoolEmail)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
            
            TextField("Your Name", text: $name)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            SecureField("Create Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Spacer() // Pushes the next button to the bottom
            
            Toggle(isOn: $termsAccepted) {
                Text("I agree to the Terms & Conditions")
                    .font(.system(size: 15))
            }
            .padding()
            
            Button(action: {
                if password != confirmPassword {
                    alertMessage = "Passwords don't match"
                    showingAlert = true
                    return
                }
                
                AuthManager.shared.registerNewUser(with: User(name: name, email: schoolEmail, password: password)) { success, errorMessage in
                    if success {
                        self.isSignupSuccessful = true
                    } else {
                        alertMessage = errorMessage ?? "An error occurred"
                        showingAlert = true
                    }
                }
            }) {
                Text("Next")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isSignupSuccessful) {
                HomeView()
            }
        }
        .padding(.horizontal)
    }
}
