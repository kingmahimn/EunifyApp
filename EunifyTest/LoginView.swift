import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false

    var body: some View {
        VStack(spacing: 20) {
            
            Button(action: {
                // Handle Apple ID Login
            }) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.title)
                    Text("Continue with Apple ID")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)

            Text("OR")
                .fontWeight(.medium)

            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Button(action: {
                // Handle forgot password
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
            }
            
            Spacer() // Pushes the Login button to the bottom

            Toggle(isOn: $rememberMe) {
                Text("Remember Me")
            }
            .padding()

            Button(action: {
                loginUser()
            }) {
                Text("Login")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom) // Added padding to the bottom for aesthetics
            
        }
        .padding(.horizontal)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
    }
    
    private func loginUser() {
        AuthManager.shared.loginUser(with: email, password: password) { success in
            if success {
                navigateToHome = true
            } else {
                alertMessage = "Login failed. Please check your credentials and try again."
                showingAlert = true
            }
        }
    }
}
