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
                        Text("Volunteer Hours")
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
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    @State private var showImageCropper: Bool = false
    @State private var cropPosition: CGPoint = .zero
    @State private var showProfilePictureConfirmation = false
    @State private var showCropConfirmation = false
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }

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

        Form {
            Section(header: Text("PROFILE PICTURE")) {
                ProfilePictureView(image: $profileImage, inputImage: $inputImage, showImageCropper: $showImageCropper, cropPosition: $cropPosition, showProfilePictureConfirmation: $showProfilePictureConfirmation, showCropConfirmation: $showCropConfirmation)
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            SettingsImagePicker(isShown: $showingImagePicker, image: $inputImage)
        }
        .alert(isPresented: $showProfilePictureConfirmation) {
            Alert(title: Text("Change Profile Picture"), message: Text("Are you sure you want to change your profile picture?"), primaryButton: .destructive(Text("Change")) {
                self.showingImagePicker = true
            }, secondaryButton: .cancel())
        }
        .alert(isPresented: $showCropConfirmation) {
            Alert(title: Text("Crop Profile Picture"), message: Text("Are you sure you want to crop your profile picture?"), primaryButton: .destructive(Text("Crop")) {
                self.showCropConfirmation = false
                self.showImageCropper = true
            }, secondaryButton: .cancel())
        }
    }
}

struct ProfilePictureView: View {
    @Binding var image: Image?
    @Binding var inputImage: UIImage?
    @Binding var showImageCropper: Bool
    @Binding var cropPosition: CGPoint
    @Binding var showProfilePictureConfirmation: Bool
    @Binding var showCropConfirmation: Bool
    @State private var showImagePicker = false

    var body: some View {
        VStack {
            if image != nil {
                image?
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 3)
                    .onTapGesture {
                        self.showImagePicker = true
                    }
            } else {
                Button(action: {
                    self.showImagePicker = true
                }) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 3)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            CustomImagePicker(image: self.$inputImage, showImageCropper: self.$showImageCropper, cropPosition: self.$cropPosition, showCropConfirmation: self.$showCropConfirmation) { image in
                self.image = Image(uiImage: image)
            }
        }
    }
}

struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var showImageCropper: Bool
    @Binding var cropPosition: CGPoint
    @Binding var showCropConfirmation: Bool
    var onImageSelected: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CustomImagePicker>) {

    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.showImageCropper = true
                parent.onImageSelected(uiImage)
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

struct SettingsImagePicker: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var image: UIImage?

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isShown: $isShown, image: $image)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var isShown: Bool
        @Binding var image: UIImage?

        init(isShown: Binding<Bool>, image: Binding<UIImage?>) {
            _isShown = isShown
            _image = image
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image = uiImage
            isShown = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown = false
        }
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
    @State private var selectedConsortium: String?
    @State private var consortiums = ["Consortium A", "Consortium B", "Consortium C"]
    
    var body: some View {
        List {
            Section(header: Text("CONSORTIUM")) {
                ForEach(consortiums, id: \.self) { consortium in
                    NavigationLink(destination: ConsortiumSettingsView(consortium: consortium)) {
                        HStack {
                            Text(consortium)
                            Spacer()
                            if consortium == selectedConsortium {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Consortium Settings")
    }
}

struct ConsortiumSettingsView: View {
    let consortium: String
    
    @State private var goal = "Goal"
    @State private var name = "Consortium Name"
    @State private var description = "Consortium Description"
    @State private var members = ["Alice", "Bob", "Charlie"]
    @State private var selectedMember: String?
    
    var body: some View {
        List {
            Section(header: Text("CONSORTIUM GOAL")) {
                TextField("Goal", text: $goal)
            }
            Section(header: Text("CONSORTIUM NAME")) {
                TextField("Name", text: $name)
            }
            Section(header: Text("CONSORTIUM DESCRIPTION")) {
                TextField("Description", text: $description)
            }
            Section(header: Text("CONSORTIUM MEMBERS")) {
                ForEach(members, id: \.self) { member in
                    NavigationLink(destination: MemberSettingsView(member: member)) {
                        HStack {
                            Text(member)
                            Spacer()
                            if member == selectedMember {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                Button(action: {
                    // Handle adding a new member
                }) {
                    Text("Add Member")
                }
            }
            Section(header: Text("CONSORTIUM OWNERSHIP")) {
                NavigationLink(destination: TransferOwnershipView()) {
                    Text("Transfer Ownership")
                }
            }
        }
        .navigationBarTitle(Text(consortium))
    }
}

struct MemberSettingsView: View {
    let member: String
    
    @State private var role = "Manager"
    
    var body: some View {
        List {
            Section(header: Text("MEMBER ROLE")) {
                Picker("Role", selection: $role) {
                    Text("Manager").tag("Manager")
                    Text("Co-Owner").tag("Co-Owner")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationBarTitle(Text(member))
    }
}

struct TransferOwnershipView: View {
    @State private var selectedAccount: String?
    @State private var accounts = ["Account A", "Account B", "Account C"]
    
    var body: some View {
        List {
            Section(header: Text("TRANSFER OWNERSHIP")) {
                ForEach(accounts, id: \.self) { account in
                    Button(action: {
                        self.selectedAccount = account
                    }) {
                        HStack {
                            Text(account)
                            Spacer()
                            if account == selectedAccount {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationBarTitle("Transfer Ownership")
        .padding(20)
    }
}

struct HoursView: View {
    @State private var selectedMonth = Date()
    @State private var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    @State private var hours = [
        "January": 20,
        "February": 15,
        "March": 25,
        "April": 30,
        "May": 10,
        "June": 5,
        "July": 15,
        "August": 20,
        "September": 25,
        "October": 30,
        "November": 10,
        "December": 5
    ]
    
    var availableMonths: [String] {
        months.filter { month in
            hours[month] != nil
        }
    }
    
    var totalHours: Int {
        if let month = Calendar.current.dateComponents([.month], from: selectedMonth).month, let selectedMonthName = availableMonths[optional: month - 1] {
            return hours[selectedMonthName] ?? 0
        } else {
            return 0
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Total Hours: \(totalHours)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            List {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(availableMonths, id: \.self) { month in
                        Text(month)
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal)
            
            if let month = Calendar.current.dateComponents([.month], from: selectedMonth).month, let selectedMonthName = availableMonths[optional: month - 1] {
                CircleChartView(hours: hours[selectedMonthName] ?? 0)
                    .frame(height: 200)
                    .padding(.horizontal)
                    .animation(.easeInOut)
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 20) {
                    Button(action: {
                        // Handle appeal button
                    }) {
                        Text("Appeal")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Handle redeem hours button
                    }) {
                        Text("Redeem Hours")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationBarTitle("Volunteer Hours")
    }
}

struct CircleChartView: View {
    let hours: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0, to: CGFloat(hours) / 100)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut)
            
            VStack {
                Text("\(hours)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("hours")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

extension Collection {
    subscript(optional index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
