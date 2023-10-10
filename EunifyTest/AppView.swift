import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct AddView: View {
    @State private var postContent: String = ""
    @State private var tags: String = ""
    @State private var selectedCategory: String = "Trending"
    @State private var showingImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var imageUrl: String?
    
    // Categories from HomeView
    let categories = ["Trending", "Programming", "Outdoor", "School"]
    
    var body: some View {
        VStack {
            TextField("Write your post", text: $postContent)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            TextField("Tags (e.g. #swiftui #ios)", text: $tags)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if let image = inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            Button("Select Image") {
                self.showingImagePicker = true
            }
            
            Button("Create Post") {
                savePostToFirebase()
            }
        }
        .padding()
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func savePostToFirebase() {
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        
        // If you want to save image
        if let image = inputImage {
            uploadImage(image: image) { url in
                let post = [
                    "content": self.postContent,
                    "tags": self.tags,
                    "category": self.selectedCategory,
                    "createdBy": email,
                    "time": Timestamp(),
                    "imageUrl": url?.absoluteString ?? ""
                ] as [String: Any]
                
                db.collection("posts").addDocument(data: post) { error in
                    if let e = error {
                        print("There was an issue saving data to Firestore. \(e)")
                    } else {
                        print("Successfully saved data.")
                        // Reset the input fields
                        self.postContent = ""
                        self.tags = ""
                        self.inputImage = nil
                    }
                }
            }
        } else {
            // Without image
            let post = [
                "content": self.postContent,
                "tags": self.tags,
                "category": self.selectedCategory,
                "createdBy": email,
                "time": Timestamp()
            ] as [String: Any]
            
            db.collection("posts").addDocument(data: post) { error in
                if let e = error {
                    print("There was an issue saving data to Firestore. \(e)")
                } else {
                    print("Successfully saved data.")
                    // Reset the input fields
                    self.postContent = ""
                    self.tags = ""
                }
            }
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping (URL?) -> ()) {
        let storageRef = Storage.storage().reference().child("images/posts/\(UUID().uuidString).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error fetching download URL: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    if let url = url {
                        completion(url)
                    }
                }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.inputImage = inputImage
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}
