import SwiftUI

struct TutorialView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToHome = false
    
    var body: some View {
        ZStack {
            TutorialViewControllerRepresentable(navigateToHome: $navigateToHome)
                .edgesIgnoringSafeArea(.all)
            
            NavigationLink(
                destination: HomeScreen(),
                isActive: $navigateToHome,
                label: { EmptyView() }
            )
        }
    }
}

struct TutorialViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var navigateToHome: Bool
    
    func makeUIViewController(context: Context) -> TutorialViewController {
        let controller = TutorialViewController()
        controller.onNavigateToHome = {
            navigateToHome = true
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: TutorialViewController, context: Context) {
        // Update if needed
    }
}
