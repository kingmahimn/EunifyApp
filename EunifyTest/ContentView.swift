import SwiftUI

struct ContentView: View {
    @ObservedObject var appState = AppState()
    @ObservedObject var userStore = UserStore()
    @State private var selectedTab: String = "Home"
    
    var body: some View {
        ZStack {
            if appState.isLoading {
                LoadingView()
            } else if appState.isLoggedIn {
//                HomeView().environmentObject(userStore)
                selectedPage
                customTabBar
            } else {
                NavigationView {
                    VStack {
                        NavigationLink(destination: SignupView()) {
                            Text("Sign Up")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .navigationTitle("Welcome")
                }
            }
        }
    }
    
    var selectedPage: some View {
        switch selectedTab {
            case "Home":
                return AnyView(HomeView().environmentObject(userStore))
            case "Search":
                return AnyView(HomeView().environmentObject(userStore))
            case "Consortium":
                return AnyView(AddView())
            case "Messages":
                return AnyView(HomeView().environmentObject(userStore))
            case "Settings":
                return AnyView(SettingsView())
            default:
                return AnyView(HomeView().environmentObject(userStore))
        }
    }
    
    var customTabBar: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    TabButton(selectedTab: $selectedTab, imageName: tab.icon, title: tab.title)
                }
            }
            .background(
                Color.blue.opacity(0.2)
                    .cornerRadius(15)
                    .frame(width: computeTabWidth(), height: 50)
                    .offset(x: computeOffset())
                , alignment: .leading
            )
            .background(Color(.systemBackground))
        }
    }

    func computeTabWidth() -> CGFloat {
        UIScreen.main.bounds.width / CGFloat(tabs.count)
    }

    func computeOffset() -> CGFloat {
        let tabIndex = tabs.firstIndex(where: { $0.title == selectedTab }) ?? 0
        return CGFloat(tabIndex) * computeTabWidth()
    }

    let tabs = [
        Tab(icon: "house.fill", title: "Home"),
        Tab(icon: "magnifyingglass", title: "Search"),
        Tab(icon: "rectangle.3.group.fill", title: "Consortium"),
        Tab(icon: "message.fill", title: "Messages"),
        Tab(icon: "person.crop.circle", title: "Settings")
    ]
}

struct Tab: Hashable {
    let icon: String
    let title: String
}

struct TabButton: View {
    @Binding var selectedTab: String
    var imageName: String
    var title: String
    
    var body: some View {
        Button(action: {
            withAnimation { selectedTab = title }
        }) {
            Image(systemName: imageName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(selectedTab == title ? .blue : .gray)  // Conditional color based on selection
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        }
    }
}
