import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct HomeView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedCategory: String = "Trending"
    @State private var newsPosts: [NewsItem] = []
    @State private var searchText: String = ""

    
    let categories = ["Trending", "Programming", "Outdoor", "School"]
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Dark background
                VStack {
                    searchBar
                    categorySelector
                    contentBasedOnCategory
                    Spacer()
                }
            }.onAppear(perform: fetchPosts)
        }}
    
    // MARK: - Components

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .padding(.leading, 8)
                .foregroundColor(.gray)
            
            TextField("Search...", text: $searchText)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
        }
        .padding(.horizontal)
    }
    
    var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .modifier(CategoryModifier())
                            .background(category == selectedCategory ? Color.blue : Color.clear)
                            .cornerRadius(20)
                            .foregroundColor(category == selectedCategory ? .black : .white)
                    }
                }
            }
            .padding()
        }
    }
    
    var contentBasedOnCategory: some View {
        postsForCategory(selectedCategory)
    }
    
    var trendingContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Recent")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                ForEach(newsPosts, id: \.id) { post in
                    NewsCard(item: post)
                }

            }
        }
    }
    
    func postsForCategory(_ category: String) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                Text(category)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                let filteredPosts = newsPosts.filter { $0.category == category }
                ForEach(filteredPosts, id: \.id) { post in
                    PaddedNewsCard(post: post, isLast: post == filteredPosts.last!)
                }
            }
        }
    }
    
    // MARK: - Fetching Data
    
    func fetchPosts() {
        let db = Firestore.firestore()

        db.collection("posts").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting posts: \(err)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }

            var fetchedPosts: [NewsItem] = []

            for document in documents {
                let data = document.data()
                if let content = data["content"] as? String,
                   let tags = data["tags"] as? String,
                   let createdBy = data["createdBy"] as? String,
                   let timestamp = data["time"] as? Timestamp,
                   let category = data["category"] as? String {

                    let imageUrl = data["imageUrl"] as? String
                    let time = timestamp.dateValue().timeAgoDisplay()
                    let post = NewsItem(id: document.documentID, // set the id here
                                        imageUrl: imageUrl,
                                        author: createdBy,
                                        handle: "@\(createdBy.split(separator: "@").first ?? "")",
                                        timeAgo: time,
                                        content: content,
                                        hashtags: tags,
                                        category: category,
                                        date: timestamp.dateValue())
                    fetchedPosts.append(post)
                } else {
                    print("Failed to parse post data for document: \(document.documentID)")
                    print(data)
                }
            }

            // Sort by date, most recent first
            fetchedPosts.sort { $0.date > $1.date }
            
            self.newsPosts = fetchedPosts
        }
    }
}

struct PaddedNewsCard: View {
    let post: NewsItem
    let isLast: Bool

    var body: some View {
        NavigationLink(destination: CommentView(post: post)) {
            NewsCard(item: post)
        }
        .padding(.bottom, isLast ? 50 : 0)
    }
}

struct TabModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
    }
}

struct NewsItem: Identifiable {
    var id: String
    var imageUrl: String?
    var author: String
    var handle: String
    var timeAgo: String
    var content: String
    var hashtags: String
    var category: String
    var date: Date
    
    static func ==(lhs: NewsItem, rhs: NewsItem) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}


struct CategoryModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            .foregroundColor(.white)
    }
}

struct NewsCard: View {
    var item: NewsItem
    @State private var commentInput: String = ""
    @EnvironmentObject var userStore: UserStore
    @State private var showingActionSheet = false
    @State private var showingEditView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.pink)
                
                VStack(alignment: .leading) {
                    
                    Text(item.author)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(item.handle) • \(item.timeAgo)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.gray)
                    .padding()
                    .onTapGesture {
                        showingActionSheet = true
                    }
                    .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(title: Text("Options"), buttons: [
                            .default(Text("Edit"), action: editPost),
                            .destructive(Text("Delete"), action: deletePost),
                            .cancel()
                        ])
                    }
            }
            
            // Content
            Text(item.content)
                .foregroundColor(.white)
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
            
            if let imageUrl = item.imageUrl {
                AsyncImage(url: imageUrl)
                    .frame(height: 200)
                    .clipped()
            }
            
            Text(item.hashtags)
                .font(.footnote)
                .foregroundColor(.blue)
            
            // Action icons
            HStack(spacing: 15) {
                Image(systemName: "arrowshape.turn.up.left")
                    .foregroundColor(.gray)
                    .font(.system(size: 20, weight: .bold))
                
                Image(systemName: "heart")
                    .foregroundColor(.gray)
                    .font(.system(size: 20, weight: .bold))
                
                TextField("Type your comment", text: $commentInput)
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
            }
            .padding(.horizontal, 10)
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .sheet(isPresented: $showingEditView) {
            EditPostView(post: item, dismissAction: {
                showingEditView = false
            })
        }
    }
    
    func editPost() {
        showingEditView = true
    }
    
    func deletePost() {
        let db = Firestore.firestore()

        // Delete the post document from Firestore
        db.collection("posts").document(item.id).delete() { err in
            if let err = err {
                print("Error removing post: \(err)")
            } else {
                print("Post successfully removed!")
                
                // Check if there's a valid imageUrl before trying to delete it from storage
                if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                    let storageRef = Storage.storage().reference(forURL: imageUrl)
                    storageRef.delete { error in
                        if let error = error {
                            print("Failed to delete the image from storage: \(error)")
                        } else {
                            print("Image successfully deleted from storage.")
                        }
                    }
                }
            }
        }
    }



}

struct Comment: Identifiable {
    var id: String
    var text: String
    var author: String
    var timestamp: Date
}

struct CommentView: View {
    var post: NewsItem
    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @EnvironmentObject var userStore: UserStore

    func fetchComments() {
        let db = Firestore.firestore()
        db.collection("posts").document(post.id).collection("comments").addSnapshotListener { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            comments = documents.compactMap { (queryDocumentSnapshot) -> Comment? in
                let data = queryDocumentSnapshot.data()
                let text = data["text"] as? String ?? ""
                let author = data["author"] as? String ?? ""
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                return Comment(id: queryDocumentSnapshot.documentID, text: text, author: author, timestamp: timestamp)  // use the document ID from Firestore
            }
        }
    }

    var body: some View {
        VStack {
            // TextField to Add Comment
            TextField("Add Your Comment. . .", text: $newComment, onCommit: {
                addComment()
            })
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .foregroundColor(.white)

            // Display Comments Here
            List(comments, id: \.id) { comment in
                VStack(alignment: .leading) {
                    Text(comment.author)
                        .font(.headline)
                    Text(comment.text)
                    Text(comment.timestamp.timeAgoDisplay())
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear(perform: fetchComments)
    }

    func addComment() {
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "text": newComment,
            "author": userStore.displayName ?? "Anonymous",
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("posts").document(post.id).collection("comments").addDocument(data: data) { err in
            if let err = err {
                print("Error adding comment: \(err)")
            } else {
                newComment = ""
                print("Comment successfully added!")
            }
        }
    }
}

struct AsyncImage: View {
    @State private var image: UIImage?
    @State private var showDetailImage = false
    let url: String
    
    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                    .onTapGesture {
                        showDetailImage = true
                    }
                    .sheet(isPresented: $showDetailImage) {
                        DetailImageView(image: img)
                    }
            } else {
                // Placeholder until the image loads
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
            }
        }
        .onAppear(perform: loadImage)
    }

    func loadImage() {
        guard let imgUrl = URL(string: url) else {
            print("Invalid URL.")
            return
        }

        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: imgUrl), let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = img
                }
            } else {
                print("Error fetching image.")
            }
        }
    }
}

struct DetailImageView: View {
    var image: UIImage

    var body: some View {
        ZStack {
            // Blur the background
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                .blur(radius: 40)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(radius: 20)
                .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            // Close the view when tapped anywhere
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
}

struct EditPostView: View {
    var post: NewsItem
    @State private var updatedContent: String
    @State private var updatedHashtags: String
    @State private var updatedCategory: String
    @State private var updatedImage: UIImage?  // Use this if you want to allow changing the image too
    @Environment(\.presentationMode) var presentationMode
    let dismissAction: () -> Void        //... (rest of your properties)
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?


    init(post: NewsItem, dismissAction: @escaping () -> Void) {
        self.post = post
        self.dismissAction = dismissAction
        _updatedContent = State(initialValue: post.content)
        _updatedHashtags = State(initialValue: post.hashtags)
        _updatedCategory = State(initialValue: post.category)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            TextField("Update post content", text: $updatedContent)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            TextField("Update Hashtags", text: $updatedHashtags)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button("Choose Image") {
                showingImagePicker = true
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: uploadImage) {
                ImagePicker(image: $selectedImage)
            }

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }

            
            Picker("Category", selection: $updatedCategory) {
                ForEach(["Trending", "Programming", "Outdoor", "School"], id: \.self) {
                    Text($0)
                }
            }
            
            // You might want to add a control here to change/update the image too.
            
            HStack {
                Button("Cancel") {
                    dismissAction()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Update") {
                    saveChanges()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }

    func saveChanges() {
        let db = Firestore.firestore()
        
        let updatedData: [String: Any] = [
            "content": updatedContent,
            "tags": updatedHashtags,
            "category": updatedCategory
            // Add the image URL here after you upload the updated image to Firebase Storage.
        ]

        db.collection("posts").document(post.id).setData(updatedData, merge: true) { error in
            if let error = error {
                print("There was an error updating the post: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
                print("Updated Hashtags: \(updatedHashtags)")
            }
        }
        dismissAction()
    }
    
    func uploadImage() {
        guard let image = selectedImage, let data = image.jpegData(compressionQuality: 0.9) else { return }
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Check if there's an existing image
        let imageRef: StorageReference
        if let existingImageUrl = post.imageUrl, let imageURL = URL(string: existingImageUrl) {
            imageRef = storage.reference(forURL: imageURL.absoluteString)
        } else {
            // If no existing image, create a new reference
            imageRef = storageRef.child("post_images/\(UUID().uuidString).jpg")
        }

        imageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }

            // Get the image URL
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                guard let imageUrl = url?.absoluteString else { return }

                // Update Firestore with new image URL
                let db = Firestore.firestore()
                db.collection("posts").document(post.id).updateData([
                    "imageUrl": imageUrl
                ]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
