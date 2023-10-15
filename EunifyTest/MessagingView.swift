import SwiftUI

struct MessagingView: View {
    @State private var messageText = ""
    @State private var messages: [[String: String]] = [
        ["sender": "user", "message": "Hello!"],
        ["sender": "other", "message": "Hi there!"],
        ["sender": "user", "message": "How are you?"],
        ["sender": "other", "message": "I'm doing well, thanks."],
        ["sender": "user", "message": "What have you been up to?"],
        ["sender": "other", "message": "Not much, just working on some projects."],
        ["sender": "user", "message": "That sounds interesting. What kind of projects?"],
        ["sender": "other", "message": "Just some personal coding projects."],
        ["sender": "user", "message": "Cool, what kind of things are you working on?"],
        ["sender": "other", "message": "I'm working on a new app idea that I came up with."],
        ["sender": "user", "message": "That's awesome! What's the app about?"],
        ["sender": "other", "message": "It's a social networking app for developers."],
        ["sender": "user", "message": "Wow, that sounds really cool!"],
        ["sender": "other", "message": "Thanks! I'm really excited about it."],
        ["sender": "user", "message": "When do you think it will be ready?"],
        ["sender": "other", "message": "Hopefully in a few months. I still have a lot of work to do."],
    ]
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                List {
                    ForEach(messages, id: \.self) { message in
                        let isImage = message["image"] != nil
                        if message["sender"]! as! String == "user" {
                            HStack {
                                Spacer()
                                if let text = message["message"] as? String {
                                    Text(text)
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                } else if isImage {
                                    let imageData = Data(base64Encoded: message["image"] as! String)!
                                    let uiImage = UIImage(data: imageData)!
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200, height: 200)
                                        .cornerRadius(10)
                                }
                            }
                        } else {
                            HStack {
                                if let text = message["message"] as? String {
                                    Text(text)
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(Color(.green))
                                        .cornerRadius(10)
                                } else if isImage {
                                    let imageData = Data(base64Encoded: message["image"] as! String)!
                                    let uiImage = UIImage(data: imageData)!
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200, height: 200)
                                        .cornerRadius(10)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                HStack {
                    Button(action: {
                        self.showImagePicker = true
                    }) {
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                    
                    TextField("iMessage", text: $messageText)
                        .padding(20)
                        .background(Color(.systemGray2))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        if let image = self.selectedImage {
                            let imageData = image.jpegData(compressionQuality: 0.5)!
                            let base64Image = imageData.base64EncodedString()
                            messages.append(["sender": "user", "image": base64Image])
                            self.selectedImage = nil
                        } else if !messageText.isEmpty {
                            messages.append(["sender": "user", "message": messageText])
                            messageText = ""
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)
                }
            }
            .navigationBarTitle("Messages")
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$selectedImage)
        }
    }
}

