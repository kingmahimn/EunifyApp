import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    NavigationLink(destination: ProfileView()) {
                        Text("Profile")
                    }
                    NavigationLink(destination: NotificationsView()) {
                        Text("Notifications")
                    }
                    NavigationLink(destination: AccountView()) {
                        Text("Account Settings")
                    }
                }
                Section(header: Text("Privacy & Security")) {
                    NavigationLink(destination: PrivacyView()) {
                        Text("Privacy Settings")
                    }
                    NavigationLink(destination: SecurityView()) {
                        Text("Eunify Policies")
                    }
                }
                Section(header: Text("Other")) {
                    NavigationLink(destination: FriendsView()) {
                        Text("Friends List")
                    }
                    NavigationLink(destination: ConsortiumView()) {
                        Text("Consortium Settings")
                    }
                    NavigationLink(destination: HoursView()) {
                        Text("Hours of Operation")
                    }
                }
                Section {
                    Button(action: {
                        // Handle logout action
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct ProfileView: View {
    @State private var displayName = "John Doe"
    @State private var emailAddress = "johndoe@example.com"
    @State private var bio = "I'm a software developer."
    
    var body: some View {
        Form {
            Section(header: Text("DISPLAY NAME")) {
                TextField("Display Name", text: $displayName)
            }
            Section(header: Text("EMAIL ADDRESS")) {
                TextField("Email Address", text: $emailAddress)
            }
            Section(header: Text("BIO/DESCRIPTION")) {
                TextEditor(text: $bio)
            }
        }
        .navigationBarTitle("Profile")
    }
}

struct NotificationsView: View {
    @State private var notificationsEnabled = true
    
    var body: some View {
        Form {
            Toggle("Notifications", isOn: $notificationsEnabled)
        }
        .navigationBarTitle("Notifications")
    }
}

struct AccountView: View {
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showLoginActivity = false
    @State private var connectedAccounts = ["Google", "Facebook"]
    
    var body: some View {
        Form {
            Section(header: Text("PASSWORD")) {
                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
            }
            Section(header: Text("LOGIN ACTIVITY")) {
                Toggle("Show Login Activity", isOn: $showLoginActivity)
            }
            Section(header: Text("CONNECTED ACCOUNTS")) {
                ForEach(connectedAccounts, id: \.self) { account in
                    Text(account)
                }
                Button(action: {
                    // Handle adding a new connected account
                }) {
                    Text("Add Account")
                }
            }
            Section {
                Button(action: {
                    // Handle password change confirmation
                }) {
                    Text("Confirm Password Change")
                }
                .foregroundColor(.blue)
            }
        }
        .navigationBarTitle("Account Settings")
    }
}

struct PrivacyView: View {
    @State private var allowLocationAccess = true
    @State private var allowCameraAccess = false
    @State private var allowMicrophoneAccess = false
    @State private var allowContactsAccess = true
    
    var body: some View {
        Form {
            Section(header: Text("LOCATION")) {
                Toggle("Allow Location Access", isOn: $allowLocationAccess)
            }
            Section(header: Text("CAMERA")) {
                Toggle("Allow Camera Access", isOn: $allowCameraAccess)
            }
            Section(header: Text("MICROPHONE")) {
                Toggle("Allow Microphone Access", isOn: $allowMicrophoneAccess)
            }
            Section(header: Text("CONTACTS")) {
                Toggle("Allow Contacts Access", isOn: $allowContactsAccess)
            }
        }
        .navigationBarTitle("Privacy Settings")
    }
}

struct SecurityView: View {
    var body: some View {
        Form {
            Section(header: Text("LEGAL")) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
                NavigationLink(destination: VolunteerHoursView()) {
                    Text("Volunteer Hours Policy")
                }
                NavigationLink(destination: TermsAndConditionsView()) {
                    Text("Terms & Conditions")
                }
            }
        }
        .navigationBarTitle("Security Settings")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy View")
            .navigationBarTitle("Privacy Policy")
    }
}

struct VolunteerHoursView: View {
    var body: some View {
        Text("Volunteer Hours Policy View")
            .navigationBarTitle("Volunteer Hours Policy")
    }
}

struct TermsAndConditionsView: View {
    var body: some View {
        Text("Terms & Conditions View")
            .navigationBarTitle("Terms & Conditions")
    }
}

struct FriendsView: View {
    @State private var friends = ["Alice", "Bob", "Charlie"]
    
    var body: some View {
        Form {
            Section(header: Text("FRIENDS")) {
                ForEach(friends, id: \.self) { friend in
                    Text(friend)
                }
                Button(action: {
                    // Handle adding a new friend
                }) {
                    Text("Add Friend")
                }
            }
            Section(header: Text("FRIEND REQUESTS")) {
                Text("No friend requests")
            }
            Section(header: Text("BLOCKED USERS")) {
                Text("No blocked users")
            }
        }
        .navigationBarTitle("Friends List")
    }
}

struct ConsortiumView: View {
    @State private var selectedConsortium = "Consortium A"
    @State private var consortiums = ["Consortium A", "Consortium B", "Consortium C"]
    
    var body: some View {
        List {
            Section(header: Text("CONSORTIUM")) {
                ForEach(consortiums, id: \.self) { consortium in
                    Button(action: {
                        self.selectedConsortium = consortium
                    }) {
                        HStack {
                            Text(consortium)
                            Spacer()
                            if consortium == selectedConsortium {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            Section(header: Text("CONSORTIUM SETTINGS")) {
                if selectedConsortium == "Consortium A" {
                    ConsortiumASettingsView()
                } else if selectedConsortium == "Consortium B" {
                    ConsortiumBSettingsView()
                } else if selectedConsortium == "Consortium C" {
                    ConsortiumCSettingsView()
                }
            }
        }
        .navigationBarTitle("Consortium Settings")
    }
}

struct ConsortiumASettingsView: View {
    @State private var allowNotifications = true
    @State private var allowLocationAccess = false
    @State private var allowCameraAccess = false
    @State private var allowMicrophoneAccess = false
    
    var body: some View {
        List {
            Toggle("Allow Notifications", isOn: $allowNotifications)
            Toggle("Allow Location Access", isOn: $allowLocationAccess)
            Toggle("Allow Camera Access", isOn: $allowCameraAccess)
            Toggle("Allow Microphone Access", isOn: $allowMicrophoneAccess)
        }
    }
}

struct ConsortiumBSettingsView: View {
    @State private var allowNotifications = false
    @State private var allowLocationAccess = true
    @State private var allowCameraAccess = false
    @State private var allowMicrophoneAccess = false
    
    var body: some View {
        List {
            Toggle("Allow Notifications", isOn: $allowNotifications)
            Toggle("Allow Location Access", isOn: $allowLocationAccess)
            Toggle("Allow Camera Access", isOn: $allowCameraAccess)
            Toggle("Allow Microphone Access", isOn: $allowMicrophoneAccess)
        }
    }
}

struct ConsortiumCSettingsView: View {
    @State private var allowNotifications = false
    @State private var allowLocationAccess = false
    @State private var allowCameraAccess = true
    @State private var allowMicrophoneAccess = false
    
    var body: some View {
        List {
            Toggle("Allow Notifications", isOn: $allowNotifications)
            Toggle("Allow Location Access", isOn: $allowLocationAccess)
            Toggle("Allow Camera Access", isOn: $allowCameraAccess)
            Toggle("Allow Microphone Access", isOn: $allowMicrophoneAccess)
        }
    }
}
struct HoursView: View {
    var body: some View {
        Text("Hours of Operation View")
            .navigationBarTitle("Hours of Operation")
    }
}
